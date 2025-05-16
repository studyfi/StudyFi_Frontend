import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/comment_model.dart';
import 'package:studyfi/models/post_model.dart';
import 'package:studyfi/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostsPage extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String? groupImageUrl;

  const PostsPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    this.groupImageUrl,
  }) : super(key: key);

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postsFuture;
  final TextEditingController _postController = TextEditingController();
  bool _isCreatingPost = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isShowingComments = false;
  int? _expandedPostId;
  Map<int, List<Comment>> _commentsCache = {};
  Map<int, Map<String, dynamic>> _likesCache = {};
  final FocusNode _postFocusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _postFocusNode.addListener(() {
      if (_postFocusNode.hasFocus && !_isExpanded) {
        setState(() {
          _isExpanded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _postController.dispose();
    _postFocusNode.dispose();
    super.dispose();
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = _apiService.fetchGroupPosts(widget.groupId);
    });
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return timeago.format(date);
    } catch (e) {
      return 'Unknown time';
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) {
      _showSnackBar('Post content cannot be empty', isError: true);
      return;
    }
    setState(() {
      _isCreatingPost = true;
    });
    try {
      final success = await _apiService.createPost(
        widget.groupId,
        _postController.text.trim(),
      );
      if (success) {
        _showSnackBar('Post created successfully');
        _postController.clear();
        setState(() {
          _isExpanded = false;
        });
        _loadPosts();
      } else {
        _showSnackBar('Failed to create post', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isCreatingPost = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Constants.dgreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 20,
          left: 20,
        ),
      ),
    );
  }

  Future<void> _loadLikes(int postId) async {
    if (_likesCache.containsKey(postId)) return;
    try {
      final likesData = await _apiService.fetchPostLikes(postId);
      setState(() {
        _likesCache[postId] = likesData;
      });
    } catch (e) {
      _showSnackBar('Error loading likes: ${e.toString()}', isError: true);
    }
  }

  Future<void> _likePost(int postId) async {
    try {
      final likesData = _likesCache[postId];
      final isLiked = likesData?['likedByCurrentUser'] ?? false;
      final success = isLiked
          ? await _apiService.unlikePost(postId)
          : await _apiService.likePost(postId);
      if (success) {
        setState(() {
          _likesCache.remove(postId);
        });
        await _loadLikes(postId);
        _loadPosts();
      } else {
        _showSnackBar('Failed to ${isLiked ? 'unlike' : 'like'} post',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> _loadComments(int postId) async {
    if (_commentsCache.containsKey(postId)) return;
    try {
      final comments = await _apiService.fetchPostComments(postId);
      setState(() {
        _commentsCache[postId] = comments;
      });
    } catch (e) {
      _showSnackBar('Error loading comments: ${e.toString()}', isError: true);
    }
  }

  void _toggleComments(int postId) {
    setState(() {
      if (_expandedPostId == postId) {
        _expandedPostId = null;
        _isShowingComments = false;
      } else {
        _expandedPostId = postId;
        _isShowingComments = true;
        _loadComments(postId);
      }
    });
  }

  void _showAddCommentDialog(int postId) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Constants.dgreen.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Comment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constants.dgreen,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Type your comment here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        BorderSide(color: Constants.dgreen.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Constants.dgreen, width: 2),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
                autofocus: true,
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) {
                      _showSnackBar('Comment cannot be empty', isError: true);
                      return;
                    }
                    Navigator.of(context).pop();
                    final success = await _apiService.commentOnPost(
                      postId,
                      commentController.text.trim(),
                    );
                    if (success) {
                      _showSnackBar('Comment added successfully');
                      if (_commentsCache.containsKey(postId)) {
                        _commentsCache.remove(postId);
                      }
                      _loadPosts();
                      if (_expandedPostId == postId) {
                        _loadComments(postId);
                      }
                    } else {
                      _showSnackBar('Failed to add comment', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.dgreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Post Comment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsList(int postId) {
    if (!_commentsCache.containsKey(postId)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Constants.dgreen),
          ),
        ),
      );
    }
    final comments = _commentsCache[postId]!;
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'No comments yet. Be the first to comment!',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        Divider(thickness: 1, color: Constants.lgreen),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Comments (${comments.length})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Constants.dgreen,
              ),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Constants.lgreen,
                    backgroundImage: comment.user.profileImageUrl != null
                        ? NetworkImage(comment.user.profileImageUrl!)
                        : AssetImage('assets/profile_placeholder.png')
                            as ImageProvider,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comment.user.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _formatTimestamp(comment.timestamp),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          comment.content,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Constants.dgreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            if (widget.groupImageUrl != null) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: widget.groupImageUrl!.isNotEmpty
                    ? (widget.groupImageUrl!.startsWith('http')
                    ? NetworkImage(widget.groupImageUrl!)
                    : AssetImage(widget.groupImageUrl!) as ImageProvider)
                    : AssetImage('assets/group_icon.jpg'),
              ),
              SizedBox(width: 10),
            ],
            Expanded(
              child: CustomPoppinsText(
                text: widget.groupName,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Constants.dgreen,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Constants.dgreen),
            onPressed: () {
              _showSnackBar('Group information coming soon!');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? 180 : 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Constants.dgreen.withOpacity(0.05),
                  offset: Offset(0, 2),
                  blurRadius: 5,
                )
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _postFocusNode.hasFocus
                            ? Constants.dgreen
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _postController,
                      focusNode: _postFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Share something with the group...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: _isExpanded ? 50 : 0,
                  padding: EdgeInsets.only(top: _isExpanded ? 10 : 0),
                  child: _isExpanded
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = false;
                                  _postFocusNode.unfocus();
                                });
                              },
                              icon: Icon(Icons.close, color: Colors.grey[700]),
                              label: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isCreatingPost ? null : _createPost,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.dgreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: _isCreatingPost
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Icon(Icons.send, size: 16),
                                        SizedBox(width: 8),
                                        Text(
                                          'Post',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        )
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Constants.dgreen),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading posts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pull down to try again',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.post_add,
                          color: Colors.grey[400],
                          size: 60,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Be the first to share something!',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = true;
                            });
                            _postFocusNode.requestFocus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.dgreen,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text('Create First Post'),
                        ),
                      ],
                    ),
                  );
                }
                final posts = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    _loadPosts();
                  },
                  color: Constants.dgreen,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final isExpanded = _expandedPostId == post.postId;
                        _loadLikes(post.postId);
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 2,
                                shadowColor: Constants.dgreen.withOpacity(0.1),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onLongPress: () {
                                        _showSnackBar(
                                            'Post options coming soon!');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundImage: post.user
                                                              .profileImageUrl !=
                                                          null
                                                      ? NetworkImage(post.user
                                                          .profileImageUrl!)
                                                      : AssetImage(
                                                              'assets/profile_placeholder.png')
                                                          as ImageProvider,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        post.user.name,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        _formatTimestamp(
                                                            post.timestamp),
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: Text(
                                                post.content,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    final likesData =
                                                        _likesCache[
                                                            post.postId];
                                                    if (likesData != null &&
                                                        (likesData['likedUsers']
                                                                as List)
                                                            .isNotEmpty) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          title:
                                                              Text('Liked by'),
                                                          content: Container(
                                                            width: double
                                                                .maxFinite,
                                                            constraints:
                                                                BoxConstraints(
                                                                    maxHeight:
                                                                        300),
                                                            child: ListView
                                                                .builder(
                                                              itemCount: (likesData[
                                                                          'likedUsers']
                                                                      as List)
                                                                  .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                final user = likesData[
                                                                            'likedUsers']
                                                                        [index]
                                                                    as PostUser;
                                                                return ListTile(
                                                                  leading:
                                                                      CircleAvatar(
                                                                    backgroundImage: user.profileImageUrl !=
                                                                            null
                                                                        ? NetworkImage(user
                                                                            .profileImageUrl!)
                                                                        : AssetImage('assets/profile_placeholder.png')
                                                                            as ImageProvider,
                                                                  ),
                                                                  title: Text(
                                                                      user.name),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child:
                                                                  Text('Close'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.thumb_up,
                                                          size: 14,
                                                          color: Constants
                                                              .dgreen
                                                              .withOpacity(
                                                                  0.7)),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        '${_likesCache[post.postId]?['likeCount'] ?? post.likeCount}',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Icon(Icons.comment,
                                                    size: 14,
                                                    color: Constants.dgreen
                                                        .withOpacity(0.7)),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${post.commentCount}',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey[200]),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(15),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () =>
                                                    _likePost(post.postId),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        _likesCache[post.postId]
                                                                    ?[
                                                                    'likedByCurrentUser'] ??
                                                                false
                                                            ? Icons.thumb_up_alt
                                                            : Icons
                                                                .thumb_up_alt_outlined,
                                                        size: 18,
                                                        color: Constants.dgreen,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        _likesCache[post.postId]
                                                                    ?[
                                                                    'likedByCurrentUser'] ??
                                                                false
                                                            ? 'Unlike'
                                                            : 'Like',
                                                        style: TextStyle(
                                                          color:
                                                              Constants.dgreen,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 24,
                                            width: 1,
                                            color: Colors.grey[300],
                                          ),
                                          Expanded(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () =>
                                                    _showAddCommentDialog(
                                                        post.postId),
                                                borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.comment_outlined,
                                                        size: 18,
                                                        color: Constants.dgreen,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Comment',
                                                        style: TextStyle(
                                                          color:
                                                              Constants.dgreen,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (post.commentCount > 0)
                                      InkWell(
                                        onTap: () =>
                                            _toggleComments(post.postId),
                                        child: Container(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(15),
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  isExpanded
                                                      ? 'Hide comments'
                                                      : 'View all ${post.commentCount} comments',
                                                  style: TextStyle(
                                                    color: Constants.dgreen,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  isExpanded
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  size: 16,
                                                  color: Constants.dgreen,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (isExpanded)
                                      _buildCommentsList(post.postId),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isExpanded = true;
          });
          _postFocusNode.requestFocus();
        },
        backgroundColor: Constants.dgreen,
        child: Icon(Icons.edit, color: Colors.white),
        elevation: 4,
      ),
    );
  }
}
