module UtilityHelper
  def smart_date(date)
    return 'Today' if date.today?
    return 'Tomorrow' if date == Date.tomorrow
    return 'Yesterday' if date == Date.yesterday
    
    date.strftime('%B %d, %Y')
  end
end
