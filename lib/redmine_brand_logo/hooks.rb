# frozen_string_literal: true
module RedmineBrandLogo
  # Injects a <style> block into <head> on every page,
  # styling the header brand based on the configured display mode.
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(_context = {})
      settings = Setting.plugin_redmine_brand_logo || {}
      mode = (settings['display_mode'].presence || 'text_only').to_s
      filename = settings['logo_filename'].to_s.strip
      custom_text = settings['custom_text'].to_s.strip
      height_px = (settings['logo_height'].presence || '40').to_s.to_i.clamp(20, 120)

      # Build the dynamic CSS based on mode.
      css = +""

      if custom_text.present?
        # Replace the displayed text using ::after content (works across themes).
        css << <<~CSS
          #header h1 a { font-size: 0 !important; line-height: #{height_px}px; }
          #header h1 a::after {
            content: #{custom_text.to_json};
            font-size: 1.4rem;
            line-height: #{height_px}px;
            vertical-align: middle;
          }
        CSS
      end

      if (mode == 'logo_only' || mode == 'text_and_logo') && filename.present?
        logo_url = "/redmine_brand_logo/serve?v=#{filename.hash.abs}"
        if mode == 'logo_only'
          # Hide all text content of the brand link, show only the logo via background-image.
          css << <<~CSS
            #header h1 a {
              font-size: 0 !important;
              line-height: #{height_px}px !important;
              display: inline-block;
              background: url('#{logo_url}') no-repeat left center;
              background-size: contain;
              height: #{height_px}px;
              min-width: #{height_px}px;
              padding-left: #{height_px + 8}px; /* fallback room */
              text-indent: -9999px;
              overflow: hidden;
            }
            #header h1 a::before { content: ''; display: inline-block; width: 280px; height: #{height_px}px; }
            #header h1 a::after { content: none !important; }
          CSS
        else # text_and_logo
          css << <<~CSS
            #header h1 a {
              line-height: #{height_px}px;
              display: inline-flex;
              align-items: center;
              gap: 12px;
            }
            #header h1 a::before {
              content: '';
              display: inline-block;
              width: #{height_px}px;
              height: #{height_px}px;
              background: url('#{logo_url}') no-repeat left center;
              background-size: contain;
              flex-shrink: 0;
            }
          CSS
        end
      end

      return '' if css.blank?
      "<style id='redmine_brand_logo_style'>\n#{css}</style>\n".html_safe
    end
  end
end
