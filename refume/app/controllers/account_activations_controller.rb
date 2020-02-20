class AccountActivationsController < ApplicationController
  # action to activate users account
  def edit
    user = User.find_by(email: params[:email])
    # check if users exist, if users are already activated
    # and if the token matches with the activcation digest
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # update users activation attribute
      user.update_attribute(:activated,    true)
      user.update_attribute(:activated_at, Time.zone.now)
      log_in user
      flash[:success] = "Account activated!"

      #the matching algorithm should be called here
      if user.role.downcase == 'mentee'
        user_profile = []
        user_profile << user.email
        user_profile << user.country
        user_profile << user.language
        user_profile << user.goals
        user_profile << user.bio
        mentee = user_profile.join('|')

        mentors_profile = User.where(role: 'mentor')
        mentors = []

        mentors_profile.each do |mentor|
          mentor_profile = []
          mentor_profile << mentor.email
          mentor_profile << mentor.country
          mentor_profile << mentor.language
          mentor_profile << mentor.goals
          mentor_profile << mentor.bio
          mentors << mentor_profile.join('|')
        end

        # find match for this mentee
        # It returns a list of mentors email
        mentors_email = find_match(mentee, mentors)

        # save the result to the database
        # get the correspondingly mentors by email
        mentors_email.each do |mentor_email|
          mentor = User.where(email: mentor_email)
          Match.new(mentor_id: mentor.id, mentee_id: user.id).save
        end
      end

      #redirect user to pages based on their role selection
      #implement later here
      redirect_to user
      #redirect_to matches_path

    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
