class VoteMailer < ApplicationMailer
  def confirmation(domain, slug)
    @vote = params[:vote]

    liquid_binding = {
      'first_name' => @vote.name.split.first,
      'share_url' => @vote.share_url(domain, slug),
      'twitter_url' => @vote.twitter_url(domain, slug),
      'facebook_url' => @vote.facebook_url(domain, slug),
      'top_choice' => @vote.top_choice,
      'rank' => @vote.rank,
      'keep_or_put' => @vote.rank == '1st' ? 'keep' : 'put'
    }

    @content = Liquid::Template.parse(@vote.poll.after_action_email_body).render(liquid_binding)
    subject = Liquid::Template.parse(@vote.poll.after_action_email_subject).render(liquid_binding)

    if @vote.poll.after_action_email_fromline.present? && @vote.poll.after_action_email_subject.present?
      result = mail(to: @vote.email, from: @vote.poll.after_action_email_fromline, subject: subject)
      @vote.update_column :message_id, result.message_id
    end
  end
end
