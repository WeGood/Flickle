require 'dropbox_sdk'
require 'json'

class PhotosController < ApplicationController

	# Get your app key and secret from the Dropbox developer website
	APP_KEY = 'dhpodrtke4gs4bf'
	APP_SECRET = '9ybjatp2dwchnhq'

	# ACCESS_TYPE should be ':dropbox' or ':app_folder' as configured for your app
	ACCESS_TYPE = :app_folder

  # GET /photos
  # GET /photos.json
  def index

  	@output = Array.new
    Dir.foreach('app/assets/images/') do |item|
		  next if item == '.' or item == '..' or item.downcase == '.ds_store'
		  	@output.push(item)
		end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  
  def authorise
	  if not params[:oauth_token] then
	      dbsession = DropboxSession.new(APP_KEY, APP_SECRET)

	      session[:dropbox_session] = dbsession.serialize #serialize and save this DropboxSession

	      #pass to get_authorize_url a callback url that will return the user here
	      redirect_to dbsession.get_authorize_url url_for(:action => 'authorise')
	  else
	      # the user has returned from Dropbox
	      dbsession = DropboxSession.deserialize(session[:dropbox_session])
	      dbsession.get_access_token  #we've been authorized, so now request an access_token
	      session[:dropbox_session] = dbsession.serialize

	      redirect_to :action => 'index'
	  end
  end

  def serve
  		client = DropboxClient.new(DropboxSession.deserialize(session[:dropbox_session]), ACCESS_TYPE)
  		metadata = client.metadata('/')

			metadata["contents"].each { |content|
				image_name = content["path"].to_s
				image = client.get_file(image_name)
				File.open("app/assets/images#{image_name}",'wb') do |f|
			 		f.write image
				end
			}

			@output = "Complete"

  end


end
