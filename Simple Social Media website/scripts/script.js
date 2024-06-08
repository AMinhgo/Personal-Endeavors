$(document).ready(function () {
    // Handle like button click
    $(".like-btn").click(function () {
        var postId = $(this).data("post-id");
        handleLike(postId);
    });

    // Handle delete button click
    $(".delete-btn").click(function () {
        var postId = $(this).data("post-id");
        deletePost(postId);
    });

    // Check if there's a fragment identifier in the URL
    if (window.location.hash) {
        // Extract the post ID from the fragment identifier
        var postId = window.location.hash.substring(1); // Remove the leading #

        // Scroll to the commented post
        var postElement = document.getElementById(postId);
        if (postElement) {
            // Modify the scrolling behavior to be smooth
            postElement.style.scrollBehavior = "smooth";
            postElement.scrollIntoView();
        }
    }
});

function handleLike(postId) {
    $.ajax({
        type: 'POST',
        url: 'handle_like.php',
        data: { post_id: postId },
        success: function (response) {
            if (response === "liked") {
                $(".like-btn[data-post-id=" + postId + "]").removeClass("btn-primary").addClass("btn-success").html("Liked");
            } else if (response === "unliked") {
                $(".like-btn[data-post-id=" + postId + "]").removeClass("btn-success").addClass("btn-primary").html("Like");
            }
        },
        error: function (xhr, status, error) {
            console.error("AJAX request failed:", error);
        }
    });
}

function deletePost(postId) {
    $.ajax({
        type: 'POST',
        url: 'handle_delete.php',
        data: { post_id: postId },
        success: function (response) {
            if (response === "success") {
                location.reload();
            } else {
                console.error("Post deletion failed.");
            }
        },
        error: function (xhr, status, error) {
            console.error("AJAX request failed:", error);
        }
    });
}
