# frozen_string_literal: true
require 'fileutils'

class RedmineBrandLogoController < ApplicationController
  before_action :require_admin, except: [:serve]
  skip_before_action :check_if_login_required, only: [:serve]

  FILES_DIR = Rails.root.join('files', 'redmine_brand_logo').freeze
  ALLOWED_EXT = %w[.png .jpg .jpeg .gif .svg .webp].freeze
  MAX_BYTES = 500_000 # 500 KB safety cap

  # POST /redmine_brand_logo/upload
  # Body: multipart with 'logo' file part. Settings get the filename.
  def upload
    file = params[:logo]
    if file.blank? || !file.respond_to?(:original_filename)
      flash[:error] = l(:error_redmine_brand_logo_no_file)
      return redirect_to plugin_settings_path(id: 'redmine_brand_logo')
    end

    ext = File.extname(file.original_filename).downcase
    unless ALLOWED_EXT.include?(ext)
      flash[:error] = l(:error_redmine_brand_logo_bad_ext, exts: ALLOWED_EXT.join(', '))
      return redirect_to plugin_settings_path(id: 'redmine_brand_logo')
    end

    if file.size > MAX_BYTES
      flash[:error] = l(:error_redmine_brand_logo_too_big, max_kb: MAX_BYTES / 1024)
      return redirect_to plugin_settings_path(id: 'redmine_brand_logo')
    end

    FileUtils.mkdir_p(FILES_DIR)
    safe_name = "logo-#{Time.now.to_i}#{ext}"
    target = FILES_DIR.join(safe_name)
    File.open(target, 'wb') { |f| f.write(file.read) }

    # Remove any previously uploaded file (no garbage left behind)
    Dir.glob(FILES_DIR.join("logo-*.*")).each do |old|
      File.delete(old) unless File.basename(old) == safe_name
    end

    new_settings = (Setting.plugin_redmine_brand_logo || {}).merge('logo_filename' => safe_name)
    Setting.plugin_redmine_brand_logo = new_settings

    flash[:notice] = l(:notice_redmine_brand_logo_uploaded)
    redirect_to plugin_settings_path(id: 'redmine_brand_logo')
  end

  # GET /redmine_brand_logo/serve
  # Public — serves the configured logo file. No auth required.
  def serve
    filename = (Setting.plugin_redmine_brand_logo || {})['logo_filename'].to_s.strip
    if filename.blank? || !filename.match?(/\A[\w.\-]+\z/)
      head :not_found
      return
    end
    path = FILES_DIR.join(filename)
    unless File.exist?(path) && File.file?(path)
      head :not_found
      return
    end
    send_file path,
              type: Mime::Type.lookup_by_extension(File.extname(filename).delete('.')).to_s,
              disposition: 'inline',
              x_sendfile: false
  end

  # POST /redmine_brand_logo/remove
  def remove
    filename = (Setting.plugin_redmine_brand_logo || {})['logo_filename'].to_s.strip
    if filename.match?(/\A[\w.\-]+\z/)
      path = FILES_DIR.join(filename)
      File.delete(path) if File.exist?(path)
    end
    new_settings = (Setting.plugin_redmine_brand_logo || {}).merge('logo_filename' => '')
    Setting.plugin_redmine_brand_logo = new_settings
    flash[:notice] = l(:notice_redmine_brand_logo_removed)
    redirect_to plugin_settings_path(id: 'redmine_brand_logo')
  end
end
