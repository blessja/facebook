module ApplicationHelper
# Returns the new record created in notifications table
  def new_notification(user, notice_id, notice_type)
    notice = user.notifications.build(notice_id: notice_id,   
    notice_type: notice_type)
    user.notice_seen = false
    user.save
    notice
  end
  
  # Receives the notification object as parameter along with a type
  # and returns a User record, Post record or a Comment record
  # depending on the type supplied 
  def notification_find(notice, type)
    return User.find(notice.notice_id) if type == 'friendRequest'
    return Post.find(notice.notice_id) if type == 'comment'
    return Post.find(notice.notice_id) if type == 'like-post'
    return unless type == 'like-comment'
    comment = Comment.find(notice.notice_id)
    Post.find(comment.post_id)
  end

    # Checks whether a post or comment has already been liked by the 
  # current user returning either true or false
  def liked?(subject, type)
    result = false
    result = Like.where(user_id: current_user.id, post_id: 
                        subject.id).exists? if type == 'post'
    result = Like.where(user_id: current_user.id, comment_id: 
                        subject.id).exists? if type == 'comment'
    result
  end
  
  def friend_request_sent?(user)
    current_user.friend_sent.exists?(sent_to_id: user.id, status: false)
  end
  
  def friend_request_received?(user)
    current_user.friend_request.exists?(sent_by_id: user.id, status: false)
  end
  
  # Checks whether a user has had a friend request sent to them by the current user or 
  # if the current user has been sent a friend request by the user returning either true or false
  def possible_friend?(user)
    request_sent = current_user.friend_sent.exists?(sent_to_id: user.id)
    request_received = current_user.friend_request.exists?(sent_by_id: user.id)
    
    return true if request_sent != request_recieved    
    return true if request_sent == request_recieved && request_sent == true    
    return false if request_sent == request_recieved && request_sent == false
  end
end
