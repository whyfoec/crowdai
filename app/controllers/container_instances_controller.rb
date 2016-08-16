class ContainerInstancesController < ApplicationController
  before_action :set_container_instance, only: [:show, :edit, :update, :destroy]
  before_action :set_docker_configuration

  def index
    @container_instances = ContainerInstance.all
  end

  def show
  end

  def new
    @container_instance = ContainerInstance.new
  end

  def edit
  end

  def create
    @container_instance = ContainerInstance.new(docker_container_params)

    if @container_instance.save
      redirect_to @container_instance, notice: 'Docker container was successfully created.'
    else
      render :new
    end
  end

  def update
    if @container_instance.update(container_instance_params)
      redirect_to @container_instance, notice: 'Docker container was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @container_instance.destroy
    redirect_to containers_url, notice: 'Docker container was successfully destroyed.'
  end

  private
    def set_container_instance
      @container_instance = ContainerInstance.find(params[:id])
    end

    def set_docker_configuration
      @docker_configuration = DockerConfiguration.find(params[:docker_configuration_id])
      @challenge = @docker_configuration.challenge
    end

    def container_instance_params
      params.require(:container_instance).permit(:docker_configuration_id, :status_cd, :message, :image_sha, :container_sha)
    end
end