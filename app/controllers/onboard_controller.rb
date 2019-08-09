# frozen_string_literal: true

class OnboardController < ApplicationController
  layout 'layouts/apified'

  def index
    @theme = 'minimal'
  end
end
