/**
 * ACNHS Video Library Utilities
 * Handles Google Drive video link conversion and security
 */

const VideoLibrary = {
  /**
   * Convert Google Drive URL to embeddable preview URL
   * @param {string} driveUrl - Original Google Drive link
   * @returns {string} - Embed-ready preview URL
   */
  convertToEmbedUrl(driveUrl) {
    const fileId = this.extractFileId(driveUrl);
    if (!fileId) {
      throw new Error('Invalid Google Drive URL format');
    }
    return `https://drive.google.com/file/d/${fileId}/preview?rm=minimal`;
  },

  /**
   * Extract FILE_ID from various Google Drive URL formats
   * @param {string} url - Google Drive URL
   * @returns {string|null} - Extracted file ID or null
   */
  extractFileId(url) {
    if (!url) return null;

    // Format 1: https://drive.google.com/file/d/FILE_ID/view
    let match = url.match(/drive\.google\.com\/file\/d\/([^/?]+)/);
    if (match) return match[1];

    // Format 2: https://drive.google.com/open?id=FILE_ID
    match = url.match(/[?&]id=([^&]+)/);
    if (match) return match[1];

    // Format 3: Already just the FILE_ID (20-50 chars, no slashes)
    if (url.length >= 20 && url.length <= 50 && !url.includes('/')) {
      return url;
    }

    return null;
  },

  /**
   * Validate if URL is a valid Google Drive link
   * @param {string} url - URL to validate
   * @returns {boolean}
   */
  isValidDriveUrl(url) {
    return this.extractFileId(url) !== null;
  },

  /**
   * Create video player HTML with security measures
   * @param {string} embedUrl - Google Drive preview URL
   * @param {string} title - Video title for watermark
   * @param {string} studentId - Student ID for watermark (optional)
   * @returns {string} - HTML string for video player
   */
  createSecurePlayer(embedUrl) {
    return `
      <iframe
        src="${embedUrl}"
        style="position:absolute; top:0; left:0; width:100%; height:100%; border:none;"
        allow="autoplay; encrypted-media; fullscreen; picture-in-picture"
        allowfullscreen
        sandbox="allow-scripts allow-same-origin allow-presentation allow-fullscreen"
        loading="lazy"
      ></iframe>
      <div class="video-open-blocker" aria-hidden="true"></div>
    `;
  },

  /**
   * Fetch all published videos for students
   * @param {object} supabase - Supabase client
   * @returns {Promise<Array>} - Array of published videos
   */
  async fetchPublishedVideos(supabase) {
    const { data, error } = await supabase
      .from('video_library')
      .select('*')
      .eq('is_published', true)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching videos:', error);
      throw error;
    }

    return data || [];
  },

  /**
   * Fetch all videos (admin only)
   * @param {object} supabase - Supabase client
   * @returns {Promise<Array>} - Array of all videos
   */
  async fetchAllVideos(supabase) {
    const { data, error } = await supabase
      .from('video_library')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching videos:', error);
      throw error;
    }

    return data || [];
  },

  /**
   * Fetch videos by category
   * @param {object} supabase - Supabase client
   * @param {string} category - Category name
   * @param {boolean} publishedOnly - Only fetch published videos
   * @returns {Promise<Array>}
   */
  async fetchByCategory(supabase, category, publishedOnly = true) {
    let query = supabase
      .from('video_library')
      .select('*')
      .eq('category', category);

    if (publishedOnly) {
      query = query.eq('is_published', true);
    }

    const { data, error } = await query.order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching videos by category:', error);
      throw error;
    }

    return data || [];
  },

  /**
   * Add new video (admin only)
   * @param {object} supabase - Supabase client
   * @param {object} videoData - Video details
   * @returns {Promise<object>}
   */
  async addVideo(supabase, videoData) {
    // Auto-generate embed URL from drive URL
    const embedUrl = this.convertToEmbedUrl(videoData.drive_url);

    const { data, error } = await supabase
      .from('video_library')
      .insert([{
        title: videoData.title,
        description: videoData.description || '',
        category: videoData.category || 'General',
        drive_url: videoData.drive_url,
        embed_url: embedUrl,
        is_published: videoData.is_published || false,
        created_by: videoData.created_by || 'admin@acnhs.am',
        duration: videoData.duration || '',
        thumbnail_url: videoData.thumbnail_url || ''
      }])
      .select()
      .single();

    if (error) {
      console.error('Error adding video:', error);
      throw error;
    }

    return data;
  },

  /**
   * Update video (admin only)
   * @param {object} supabase - Supabase client
   * @param {string} videoId - Video UUID
   * @param {object} updates - Fields to update
   * @returns {Promise<object>}
   */
  async updateVideo(supabase, videoId, updates) {
    // If drive_url is being updated, regenerate embed_url
    if (updates.drive_url) {
      updates.embed_url = this.convertToEmbedUrl(updates.drive_url);
    }

    const { data, error } = await supabase
      .from('video_library')
      .update(updates)
      .eq('id', videoId)
      .select()
      .single();

    if (error) {
      console.error('Error updating video:', error);
      throw error;
    }

    return data;
  },

  /**
   * Delete video (admin only)
   * @param {object} supabase - Supabase client
   * @param {string} videoId - Video UUID
   * @returns {Promise<boolean>}
   */
  async deleteVideo(supabase, videoId) {
    const { error } = await supabase
      .from('video_library')
      .delete()
      .eq('id', videoId);

    if (error) {
      console.error('Error deleting video:', error);
      throw error;
    }

    return true;
  },

  /**
   * Increment view count for a video
   * @param {object} supabase - Supabase client
   * @param {string} videoId - Video UUID
   */
  async incrementViewCount(supabase, videoId) {
    const { data: video } = await supabase
      .from('video_library')
      .select('view_count')
      .eq('id', videoId)
      .single();

    if (video) {
      await supabase
        .from('video_library')
        .update({ view_count: (video.view_count || 0) + 1 })
        .eq('id', videoId);
    }
  },

  /**
   * Get unique categories
   * @param {object} supabase - Supabase client
   * @param {boolean} publishedOnly - Only count published videos
   * @returns {Promise<Array>}
   */
  async getCategories(supabase, publishedOnly = true) {
    let query = supabase
      .from('video_library')
      .select('category');

    if (publishedOnly) {
      query = query.eq('is_published', true);
    }

    const { data, error } = await query;

    if (error) {
      console.error('Error fetching categories:', error);
      return [];
    }

    // Get unique categories
    const categories = [...new Set(data.map(v => v.category).filter(Boolean))];
    return categories.sort();
  },

  /**
   * Security: Disable right-click on video players
   */
  applySecurityMeasures() {
    document.addEventListener('contextmenu', function(e) {
      if (e.target.closest('.video-player-wrapper')) {
        e.preventDefault();
        return false;
      }
    });

    // Prevent iframe dragging
    document.addEventListener('dragstart', function(e) {
      if (e.target.closest('.video-player-wrapper iframe')) {
        e.preventDefault();
        return false;
      }
    });
  }
};

// Auto-apply security measures on page load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    VideoLibrary.applySecurityMeasures();
  });
} else {
  VideoLibrary.applySecurityMeasures();
}

// Make available globally
window.VideoLibrary = VideoLibrary;
