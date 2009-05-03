module I18nControllerHelper
  def t(symbol, options = {})
    if symbol.to_s.match(/\A\.(.*)/)
      key = "#{params[:controller]}.#{params[:action]}.#{$1}"
    else
      key = symbol
    end
    super key, options
  end
end