FullscreenDropboxPhoto::Application.routes.draw do

  root :to => 'photos#index'
  match "/photos" => "photos#index"
  match '/photos/authorise' => "photos#authorise"
  match '/photos/serve' => 'photos#serve'
  

end
