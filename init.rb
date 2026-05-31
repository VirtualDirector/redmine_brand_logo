# frozen_string_literal: true
# Redmine Brand Logo plugin
# Author: Virtual Director Kft.
# License: GPLv2

require 'redmine'
require File.expand_path('lib/redmine_brand_logo/version', __dir__)
require File.expand_path('lib/redmine_brand_logo/hooks', __dir__)

Redmine::Plugin.register :redmine_brand_logo do
  name 'Redmine Brand Logo'
  author 'Virtual Director Kft.'
  author_url 'https://virtualdirector.hu'
  url 'https://github.com/VirtualDirector/redmine_brand_logo'
  description 'Add a brand logo or text to the Redmine header. Theme-independent. ' \
              'Configure mode (text only / logo only / text + logo), upload a logo image, ' \
              'or override the header text. Image is auto-scaled to fixed header height (40px).'
  version RedmineBrandLogo::VERSION

  requires_redmine version_or_higher: '6.0'

  settings default: {
             'display_mode'  => 'text_only',   # text_only | logo_only | text_and_logo
             'logo_filename' => '',            # filename inside FILES_DIR (no path)
             'custom_text'   => '',            # if blank, fall back to Setting.app_title
             'logo_height'   => '40'           # px; logo width is auto-scaled proportionally
           },
           partial: 'settings/redmine_brand_logo'
end
