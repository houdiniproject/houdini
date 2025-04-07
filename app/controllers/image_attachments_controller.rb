# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ImageAttachmentsController < ApplicationController
  before_action :authenticate_confirmed_user!
  def create
    # must return json with a link attr
    # http://editor.froala.com/server-integrations/php-image-upload
    @image = ImageAttachment.new(clean_params_create)
    if @image.save
      render json: {link: url_for(@image.file)}
    else
      render json: @image.errors.full_messages, status: :unprocessable_entity
    end
  end

  def remove
    @image = ImageAttachment.select { |img| url_for(img.file) == clean_params_remove[:src] }.first
    if @image
      @image.destroy
      render json: @image
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  private

  def clean_params_create
    params.require(:file)
  end

  def clean_params_remove
    params.require(:src)
  end
end
