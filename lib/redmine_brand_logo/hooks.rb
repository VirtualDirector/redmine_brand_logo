# frozen_string_literal: true
module RedmineBrandLogo
  # Injects a <style> block into <head> on every page,
  # styling the header brand based on the configured display mode.
  #
  # The Redmine base layout renders the header as:
  #   <div id="header"><h1><%= page_header_title %></h1>...</div>
  # where page_header_title is either a plain string (Setting.app_title) on
  # most pages, or an <a> link when inside a project. We style #header h1
  # directly so the rules apply regardless.
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(_context = {})
      settings = Setting.plugin_redmine_brand_logo || {}
      mode = (settings['display_mode'].presence || 'text_only').to_s
      filename = settings['logo_filename'].to_s.strip
      custom_text = settings['custom_text'].to_s.strip
      height_px = (settings['logo_height'].presence || '40').to_s.to_i.clamp(20, 120)

      css = +""

      # Add a small bottom margin on the header h1 so the #main-menu below
      # doesn't visually overlap the logo / branded title. Applied for ANY
      # plugin-configured mode (text-override, logo-only, text+logo).
      if custom_text.present? || filename.present?
        css << <<~CSS
          #header h1 { margin-bottom: 10px !important; }
        CSS
      end

      # If a custom text is set, replace the displayed header text with it,
      # regardless of mode. Implemented by hiding the <h1>'s own text (font-size:0)
      # and using a ::after pseudo-element to inject the new label.
      if custom_text.present?
        css << <<~CSS
          #header h1 {
            font-size: 0 !important;
            line-height: #{height_px}px !important;
          }
          #header h1::after {
            content: #{custom_text.to_json} !important;
            font-size: 1.4rem !important;
            line-height: #{height_px}px;
            vertical-align: middle;
            font-weight: 700;
          }
          /* If page_header_title rendered as a <a> link inside h1 (project pages),
             hide its inner text too. */
          #header h1 a {
            font-size: 0 !important;
            color: inherit;
          }
          #header h1 a::after {
            content: #{custom_text.to_json} !important;
            font-size: 1.4rem !important;
            color: inherit;
          }
        CSS
      end

      if (mode == 'logo_only' || mode == 'text_and_logo') && filename.present?
        logo_url = "/redmine_brand_logo/serve?v=#{filename.hash.abs}"

        if mode == 'logo_only'
          # Hide all text in the header; show only the logo as the h1 background.
          css << <<~CSS
            #header h1 {
              font-size: 0 !important;
              line-height: #{height_px}px !important;
              min-height: #{height_px}px;
              display: inline-block !important;
              background: url('#{logo_url}') no-repeat left center !important;
              background-size: contain !important;
              padding-left: 0 !important;
            }
            #header h1::before {
              content: '' !important;
              display: inline-block !important;
              width: 280px;
              height: #{height_px}px;
            }
            #header h1::after { content: none !important; }
            #header h1 a { display: none !important; }
          CSS
        else # text_and_logo
          css << <<~CSS
            #header h1 {
              line-height: #{height_px}px !important;
              display: inline-flex !important;
              align-items: center !important;
              gap: 12px !important;
            }
            #header h1::before {
              content: '' !important;
              display: inline-block !important;
              width: #{height_px}px;
              height: #{height_px}px;
              background: url('#{logo_url}') no-repeat left center !important;
              background-size: contain !important;
              flex-shrink: 0;
              order: -1;
            }
          CSS
        end
      end

      return '' if css.blank?
      "<style id='redmine_brand_logo_style'>\n#{css}</style>\n".html_safe
    end
  end
end
