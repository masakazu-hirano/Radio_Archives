class ProgramSelectsController < ApplicationController
  before_action :authenticate_user

  def index
    unless cookies.signed[:program].blank?
      @programs = Program.select(:id, :on_air, :already_play).readonly

      aws_credential
      if cookies.signed[:program]['name'] == 'JOAV_Mon_18:30'

      elsif cookies.signed[:program]['name'] == 'JOAV_Sun_19:00'
        @image_url = presign_url('images/BRIDGESTONE DRIVE TO THE FUTURE.webp', 60)
      end
    end
  end

  def confirm
    if params[:commit] == 'MIX MACHINE From. GROOVE LINE'
      create_cookies_program('JOAV_Mon_18:30')
      redirect_to piston2438_players_path
    elsif params[:commit] == 'BRIDGESTONE DRIVE TO THE FUTURE'
      create_cookies_program('JOAV_Sun_19:00')
      redirect_to program_selects_path
    end
  end

  def show
    @program = Program.find(params[:id].to_i)

    aws_credential
    @image_url = presign_url('images/BRIDGESTONE DRIVE TO THE FUTURE.webp', 60)
    @audio_url = presign_url(@program.s3_key, 3600)
  end

  def play
    if request.post?
      Program.update(params[:id].to_i, already_play: true)
      redirect_to program_select_path(id: params[:id].to_i)
    elsif request.delete?
      Program.update(params[:id].to_i, already_play: false)
      redirect_to program_select_path(id: params[:id].to_i)
    end
  end

  def create
    redirect_to program_select_path(id: date_params[:broadcast_date].to_i)
  end

  def destroy_cookie
    cookies.signed[:program] = nil
    redirect_to program_selects_path
  end

  private
  def create_cookies_program(value)
    cookies.signed[:program] = {
      value: {
        name: value,
      }, expires: 1.day
    }
  end

  def date_params
    params.permit(:broadcast_date)
  end
end
