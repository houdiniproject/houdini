module PaymentDupes
  def self.copy_dedication(source, target)
    return true if source.donation.dedication.blank?
    return true if target.donation.dedication.present? && (source.donation.dedication.blank? || target.donation.dedication == source.donation.dedication)
    return false if target.donation.dedication.present?
    target.donation.dedication = source.donation.dedication
    target.donation.save!
  end

  def self.can_copy_dedication?(source, target)
    return true if source.donation.dedication.blank?
    return true if target.donation.dedication.present? && (source.donation.dedication.blank? || target.donation.dedication == source.donation.dedication)
    return false if target.donation.dedication.present?
    true
  end

  def self.copy_designation(src, target, designations_to_become_comments)
    if designations_to_become_comments.include?(src.donation.designation)
      if target.donation&.comment&.include?("Designation: #{src.donation.designation}")
        # Already copied, no need to copy again
        return true
      end
      if target.donation.comment.blank?
        target.donation.comment = "Designation: " + src.donation.designation
      else
        target.donation.comment += " \nDesignation: " + src.donation.designation
      end
      src.donation.designation = nil
      target.donation.save!
      src.donation.save!
      return true
    end
    return true if src.donation.designation.blank?
    return true if target.donation.designation.present? && (src.donation.designation.blank? || target.donation.designation == src.donation.designation)
    return false if target.donation.dedication.present?
    target.donation.designation = src.donation.designation
    target.donation.save!
  end

  def self.can_copy_designation?(src, target, designations_to_become_comments)
    if designations_to_become_comments.include?(src.donation.designation)
      return true
    end
    return true if src.donation.designation.blank?
    return true if target.donation.designation.present? && (src.donation.designation.blank? || target.donation.designation == src.donation.designation)
    return false if target.donation.designation.present?
    true
  end

  def self.copy_comment(source, target, designations_to_become_comments)
    return true if source.donation.comment.blank?
    return true if target.donation.comment.present? && (source.donation.comment.blank? || target.donation.comment == source.donation.comment)
    if target.donation.comment.present?
      if designations_to_become_comments.any? { |d| target.donation.comment.include?(d) }
        designations_already_copied_to_comment = designations_to_become_comments.select { |d| target.donation.comment.include?(d) }
        comment = target.donation.comment
        designations_already_copied_to_comment.each do |d|
          comment = comment.gsub(" \nDesignation: #{d}", "")
          comment = comment.gsub("Designation: #{d}", "")
        end
        return true if source.donation.comment.blank? || comment == source.donation.comment
      else
        return false
      end
    end
    target.donation.comment = source.donation.comment
    target.donation.save!
  end

  def self.can_copy_comment?(source, target, designations_to_become_comments)
    return true if source.donation.comment.blank?
    return true if target.donation.comment.present? && (source.donation.comment.blank? || target.donation.comment == source.donation.comment)
    if target.donation.comment.present?
      if designations_to_become_comments.any? { |d| target.donation.comment.include?(d) }
        designations_already_copied_to_comment = designations_to_become_comments.select { |d| target.donation.comment.include?(d) }
        comment = target.donation.comment
        designations_already_copied_to_comment.each do |d|
          comment = comment.gsub(" \nDesignation: #{d}", "")
          comment = comment.gsub("Designation: #{d}", "")
        end
        return source.donation.comment.blank? || comment == source.donation.comment
      else
        return false
      end
    end
    true
  end

  def self.remove_payment_dupes(np_id, designations_to_become_comments)
    deleted_payments = []
    nonprofit = Nonprofit.find(np_id)
    etap_id_cf = CustomFieldMaster.find_by(name: "E-Tapestry Id #").id
    supp = nonprofit.supporters.not_deleted.joins(:custom_field_joins).where(
      "custom_field_joins.custom_field_master_id = ?", etap_id_cf
    ).references(:custom_field_joins)

    supp.find_each do |s|
      offsite_payments = s.payments.includes(:donation).where("kind = 'OffsitePayment'").joins(:journal_entries_to_item)
      offsite_payments.find_each do |offsite|
        # match one offsite donation with an online donation if:
        # - the offsite donation was created on the same day that we ran the import and
        # - the offsite donation has the same date as the online payment
        # - there is a journal entry item for the offsite payment
        donation_or_ticket_payments = s.payments.not_matched.includes(:donation).joins(
          "LEFT JOIN nonprofits ON payments.nonprofit_id = nonprofits.id"
        ).where(
          "(kind = 'Donation' OR kind = 'Ticket' OR kind = 'RecurringDonation')
                    AND (gross_amount = ? OR net_amount = ?) AND
                    (to_char(timezone(COALESCE(nonprofits.timezone, 'UTC'), timezone('UTC', date)), 'YYYY-MM-DD') = ? OR to_char(date, 'YYYY-MM-DD') = ?)", offsite.gross_amount, offsite.gross_amount, offsite.date.strftime("%Y-%m-%d"), offsite.date.strftime("%Y-%m-%d")
        )
        donation_or_ticket_payments.find_each do |online|
          reasons = []
          ActiveRecord::Base.transaction do
            if online.kind == "Ticket"
              Activity.where(attachment_id: offsite.id, attachment_type: "Payment").destroy_all
              offsite&.offsite_payment&.destroy
              offsite.destroy
              deleted_payments << offsite.id
              if online.payment_dupe_status.present?
                online.payment_dupe_status.matched = true
                online.payment_dupe_status.matched_with_offline << offsite.id
                online.payment_dupe_status.save!
              else
                online.payment_dupe_status = PaymentDupeStatus.create!(matched: true, matched_with_offline: [offsite.id])
              end
            elsif offsite.donation.event.present? && offsite.donation.event != online.donation.event
            # different events, dont delete
            elsif offsite.donation.campaign.present? && offsite.donation.campaign != online.donation.campaign
            # different campaigns, dont delete
            else
              unless can_copy_comment?(offsite, online, designations_to_become_comments)
                reasons << "Comment"
              end
              unless can_copy_dedication?(offsite, online)
                reasons << "Dedication"
              end
              unless can_copy_designation?(offsite, online, designations_to_become_comments)
                reasons << "Designation"
              end
              if reasons.none?
                if online.kind == "RecurringDonation"
                  # addresses all the payments from that recurring donation so we avoid future problems
                  recurring_donation = online.donation
                  recurring_payments = recurring_donation.payments
                  temp_duplicate_payments = []
                  temp_offsite_matches = []
                  recurring_payments.find_each do |recurring_payment|
                    equivalent_offsite = s.payments.not_matched.where(
                      "kind = 'OffsitePayment' AND (gross_amount = ? OR gross_amount = ?) AND (to_char(payments.date, 'YYYY-MM-DD') = ? OR to_char(payments.date, 'YYYY-MM-DD') = ?)",
                      recurring_payment.gross_amount, recurring_payment.net_amount, recurring_payment.date.in_time_zone(nonprofit.timezone).strftime("%Y-%m-%d"), recurring_payment.date.strftime("%Y-%m-%d")
                    ).joins(:journal_entries_to_item)
                    if equivalent_offsite.count == 1
                      # match!
                      temp_offsite_matches << equivalent_offsite.first.id
                      temp_duplicate_payments << equivalent_offsite.first.id.to_s
                      if recurring_payment.payment_dupe_status.present?
                        recurring_payment.payment_dupe_status.matched = true
                        recurring_payment.payment_dupe_status.matched_with_offline << equivalent_offsite.first.id
                        recurring_payment.payment_dupe_status.save!
                      else
                        recurring_payment.payment_dupe_status = PaymentDupeStatus.create!(matched: true, matched_with_offline: [equivalent_offsite.first.id])
                      end
                      if equivalent_offsite.first.payment_dupe_status.present?
                        equivalent_offsite.first.payment_dupe_status.matched = true
                        equivalent_offsite.first.payment_dupe_status.matched_with_offline << equivalent_offsite.first.id
                        equivalent_offsite.first.payment_dupe_status.save!
                      else
                        equivalent_offsite.first.payment_dupe_status = PaymentDupeStatus.create!(matched: true, matched_with_offline: [equivalent_offsite.first.id])
                      end
                    end
                  end
                  if temp_offsite_matches.any?
                    # it's the same donation for all of them so
                    # we can do the copies once
                    copy_comment(offsite, online, designations_to_become_comments)
                    copy_dedication(offsite, online)
                    copy_designation(offsite, online, designations_to_become_comments)
                    deleted_payments.concat(temp_duplicate_payments)
                    # deletes matching offsites here
                    temp_duplicate_payments.each do |op|
                      op = Payment.find(op)
                      Activity.where(attachment_id: op.id, attachment_type: "Payment").destroy_all
                      op&.offsite_payment&.destroy
                      op&.donation&.destroy
                      op&.destroy
                    end
                  else
                    raise ActiveRecord::Rollback
                  end
                else
                  copy_comment(offsite, online, designations_to_become_comments)
                  copy_dedication(offsite, online)
                  copy_designation(offsite, online, designations_to_become_comments)
                  Activity.where(attachment_id: offsite.id, attachment_type: "Payment").destroy_all
                  offsite.donation.destroy
                  offsite&.offsite_payment&.destroy
                  offsite.destroy
                  deleted_payments << offsite.id.to_s
                  if online.payment_dupe_status.present?
                    online.payment_dupe_status.matched = true
                    online.payment_dupe_status.matched_with_offline << offsite.id
                    online.payment_dupe_status.save!
                  else
                    online.payment_dupe_status = PaymentDupeStatus.create!(matched: true, matched_with_offline: [offsite.id])
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
