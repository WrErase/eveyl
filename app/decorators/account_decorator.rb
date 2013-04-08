class AccountDecorator < ApplicationDecorator
  delegate :key_id, :shown_characters

  def paid_until
    if self.model.paid_until < 3.days.from_now
      the_class = 'text-error'
    elsif self.model.paid_until < 1.week.from_now
      the_class = 'text-warning'
    else
      the_class = 'text-success'
    end

    paid_str = self.model.paid_until.strftime("%F %R")
    h.content_tag(:strong, paid_str, :class => the_class)
  end

  def updated_at
    if self.model.updated_at > 3.days.ago
      the_class = 'text-error'
    elsif self.model.updated_at >= 1.day.ago
      the_class = 'text-warning'
    else
      the_class = 'text-success'
    end

    updated_str = self.model.updated_at.strftime("%F %R")
    h.content_tag(:strong, updated_str, :class => the_class)
  end
end
