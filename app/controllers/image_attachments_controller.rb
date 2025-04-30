# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ImageAttachmentsController < ApplicationController
  before_action :authenticate_confirmed_user!
  def create
    # must return json with a link attr
    # http://editor.froala.com/server-integrations/php-image-upload
    @image = ImageAttachment.new(file: params[:file])
    if @image.save
      render json: {link: @image.file_url}
    else
      render json: @image.errors.full_messages, status: :unprocessable_entity
    end
  end

  def remove
    @image = ImageAttachment.select { |img| img.file_url == params[:src] }.first
    if @image
      @image.destroy
      render json: @image
    else
      render json: {}, status: :unprocessable_entity
    end
  end
end
