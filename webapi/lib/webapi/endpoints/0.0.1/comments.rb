# -*- coding: utf-8 -*-

require 'webapi/endpoints/0.0.1/responses/comments'

Webapi::Endpoints::V001::Webapi.namespace '/comments' do
  get do
    # description 'Show list for the comments.'
    comments = M::Comment.dataset
    collection_respond_with(comments) do |c|
      R::CommentCollection.new(c).generate
    end
  end

  get '/:id' do
    # description 'Show detail the comment.'
    comment = M::Comment[params["id"]]
    raise E::UnknownComments, params["id"] if comment.nil?
    respond_with(R::Comment.new(comment).generate)
  end

  post do
    # description 'Resiter a new comment'
    # params name, string
    # params comment, text
    raise E::NotFoundParameter, "not found display_name parameter" if params["display_name"].nil?
    raise E::NotFoundParameter, "not found comment parameter" if params["comment"].nil?
    comment = M::Comment.create(:display_name => params["display_name"],
                      :comment => params["comment"])
    respond_with(R::Comment.new(comment).generate)
  end

  put do
    405
  end

  put '/:id' do
    # description 'Update parameter for the comment.'
    400
  end

  delete do
    405
  end

  delete '/:id' do
    # description 'Delete the comment.'
    400
  end
end
