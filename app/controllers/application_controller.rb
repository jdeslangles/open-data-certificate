class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  # pick the locale from ?locale=X in the url,  a prettier
  # solution might be used down the line, maybe depending
  # on the ui or user preferences maybe.
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # maintain the locale param on any urls
  def default_url_options(options={})
    { :locale => I18n.locale }
  end

  def home
    unless current_user
      @surveys = Survey.available_to_complete
    end
    render '/home/index'
  end

  def start_questionnaire
    # TODO: DRY me up, as this is pretty much a duplicate of the datasets_controller#start_questionnaire action
    if params[:survey_access_code].blank?
      flash[:notice] = t('surveyor.please_choose_a_legislation')
      redirect_to root_url and return
    end

    surveys = Survey.where(:access_code => params[:survey_access_code]).order("survey_version DESC")

    # use the most recent survey for now
    @survey = surveys.first

    @response_set = ResponseSet.create(:survey => @survey)
    if (@survey && @response_set)
      flash[:notice] = t('surveyor.survey_started_success')
      redirect_to(surveyor.edit_my_survey_path(
                    :survey_code => @survey.access_code, :response_set_code => @response_set.access_code))
    else
      flash[:notice] = t('surveyor.unable_to_find_that_legislation')
      redirect_to root_url
    end
  end

end
