# Video Library Implementation Guide for ACNHS

## ⚠️ Important Security Reality Check

**Google Drive video embedding provides:**
- ✅ View-only mode (no obvious download button)
- ✅ Restricted access via Drive permissions
- ✅ Prevention of casual downloads in UI
- ✅ Right-click disabled, watermarks, domain restrictions

**Google Drive CANNOT prevent:**
- ❌ Determined users from screen recording
- ❌ Network stream extraction by tech-savvy users
- ❌ Browser DevTools inspection of video source

**For TRUE "cannot download" protection, use:**
- Vimeo Pro/Business (DRM, domain restrictions)
- Wistia, Cloudflare Stream, Mux
- YouTube unlisted (still downloadable but less obvious)

---

## 🗄️ Step 1: Run Database Setup

1. Open Supabase SQL Editor
2. Run the file: `ADD-VIDEO-LIBRARY-TABLE.sql`
3. Verify table creation:
```sql
SELECT * FROM video_library LIMIT 1;
```

---

## 🎬 Step 2: Google Drive Setup (CRITICAL)

### Create Dedicated Video Folder:
1. In Google Drive, create folder: `ACNHS Video Library`
2. Upload your videos to this folder

### Set Folder Permissions:
**Option A - Restricted (Most Secure):**
- Share folder with specific student Google accounts only
- Set to "Viewer" access
- Disable "Editors can change permissions"

**Option B - Link Sharing (Less Secure):**
- Set to "Anyone with link can view"
- Note: Anyone with link can access

### Per-Video Settings:
1. Right-click video → Share
2. Under Advanced/Settings:
   - ✅ Disable "Viewers can download/print/copy" (if available)
   - ✅ Restrict to specific domains if using Google Workspace

### Get Video Link:
1. Right-click video → Get link
2. Copy link (format: `https://drive.google.com/file/d/FILE_ID/view`)
3. This is what admin will paste in the system

---

## 📁 Step 3: Add Files to Project

### Already Created:
- ✅ `ADD-VIDEO-LIBRARY-TABLE.sql` - Database setup
- ✅ `js/video-library.js` - Video utilities

### Need to Add Script Tags:

**In `hub.html` (Student Hub)** - Add after Supabase script:
```html
<!-- Video Library -->
<script src="js/video-library.js"></script>
```

**In `admin-hub.html` OR your admin page** - Add after Supabase script:
```html
<!-- Video Library -->
<script src="js/video-library.js"></script>
```

---

## 📐 Step 4: Student Hub - Add Sidebar Item

### Find the sidebar navigation in `hub.html`

Look for the `.sidebar` section with menu items. Add this new item:

```html
<!-- EXISTING SIDEBAR ITEMS -->
<div class="nav">
  <!-- Dashboard, Grades, etc. -->
  
  <!-- ADD THIS NEW ITEM -->
  <button class="nav-item" onclick="showView('videos')">
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <polygon points="23 7 16 12 23 17 23 7"></polygon>
      <rect x="1" y="5" width="15" height="14" rx="2" ry="2"></rect>
    </svg>
    <span>Video Library</span>
  </button>
</div>
```

---

## 📐 Step 5: Student Hub - Add Video Library Section

### Find the content area in `hub.html` where views are rendered

Add this complete video library section:

```html
<!-- VIDEO LIBRARY VIEW -->
<div id="videosView" class="view" style="display:none;">
  <div class="notes-hub">
    <!-- Header -->
    <div class="notes-topline">
      <div>
        <h2>Video Library</h2>
        <p style="color:var(--text-secondary);margin-top:8px;font-size:14px;">
          Educational videos and clinical demonstrations
        </p>
      </div>
    </div>

    <!-- Category Filter -->
    <div style="margin:24px 0;display:flex;gap:8px;flex-wrap:wrap;" id="videoCategoryFilter">
      <button class="category-btn active" data-category="all">All Videos</button>
      <!-- Categories dynamically loaded -->
    </div>

    <!-- Videos Grid -->
    <div id="videosGrid" class="notes-grid">
      <!-- Videos dynamically loaded -->
    </div>

    <!-- Loading State -->
    <div id="videosLoading" class="notes-empty" style="display:none;">
      <div style="font-size:48px;margin-bottom:16px;">⏳</div>
      <h3>Loading videos...</h3>
    </div>

    <!-- Empty State -->
    <div id="videosEmpty" class="notes-empty" style="display:none;">
      <div style="font-size:48px;margin-bottom:16px;">📹</div>
      <h3>No videos available</h3>
      <p>Check back later for educational content</p>
    </div>
  </div>
</div>

<!-- Video Player Modal -->
<div class="modal" id="videoPlayerModal" onclick="if(event.target===this) closeVideoPlayer()">
  <div class="modal-card" style="max-width:900px;width:95%;background:var(--bg-card);padding:0;overflow:hidden;">
    <!-- Video will be injected here -->
    <div id="videoPlayerContainer"></div>
    
    <!-- Video Details -->
    <div style="padding:24px;">
      <h2 id="videoModalTitle" style="margin-bottom:12px;color:var(--text-primary);"></h2>
      <p id="videoModalDescription" style="color:var(--text-secondary);line-height:1.6;"></p>
      
      <!-- Close Button -->
      <button onclick="closeVideoPlayer()" style="margin-top:20px;padding:12px 24px;background:var(--accent);color:white;border:none;border-radius:8px;font-weight:600;cursor:pointer;">
        Close Video
      </button>
    </div>
  </div>
</div>

<style>
.category-btn {
  padding: 8px 16px;
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 8px;
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}
.category-btn:hover {
  background: rgba(255,255,255,0.08);
  border-color: rgba(45,212,191,0.3);
}
.category-btn.active {
  background: var(--accent);
  color: white;
  border-color: var(--accent);
}

.video-card {
  background: var(--bg-card);
  border: 1px solid var(--card-border);
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.video-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(45,212,191,0.15);
  border-color: rgba(45,212,191,0.4);
}
.video-thumbnail {
  width: 100%;
  aspect-ratio: 16/9;
  background: linear-gradient(135deg, rgba(45,212,191,0.2), rgba(96,165,250,0.2));
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}
.video-thumbnail::before {
  content: '▶';
  font-size: 48px;
  color: white;
  opacity: 0.8;
  transition: all 0.3s;
}
.video-card:hover .video-thumbnail::before {
  transform: scale(1.2);
  opacity: 1;
}
.video-info {
  padding: 16px;
}
.video-title {
  font-size: 16px;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 8px;
  line-height: 1.3;
}
.video-description {
  font-size: 13px;
  color: var(--text-secondary);
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.video-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 12px;
  font-size: 12px;
  color: var(--text-muted);
}
.video-category-badge {
  display: inline-block;
  padding: 4px 10px;
  background: rgba(45,212,191,0.15);
  color: var(--accent);
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
}
</style>

<script>
// Student Hub - Video Library Functions
let currentVideos = [];
let currentCategory = 'all';

async function loadStudentVideos() {
  const supabase = initSupabase();
  showEl('videosLoading');
  hideEl('videosEmpty');
  hideEl('videosGrid');

  try {
    // Fetch published videos
    currentVideos = await VideoLibrary.fetchPublishedVideos(supabase);
    
    // Load categories
    await loadVideoCategories();
    
    // Render videos
    renderVideoGrid();
  } catch (error) {
    console.error('Error loading videos:', error);
    showEl('videosEmpty');
    document.querySelector('#videosEmpty h3').textContent = 'Error loading videos';
  } finally {
    hideEl('videosLoading');
  }
}

async function loadVideoCategories() {
  const supabase = initSupabase();
  const categories = await VideoLibrary.getCategories(supabase, true);
  
  const filterDiv = document.getElementById('videoCategoryFilter');
  const allBtn = filterDiv.querySelector('[data-category="all"]');
  
  // Clear existing category buttons (keep "All")
  Array.from(filterDiv.children).forEach(btn => {
    if (btn.dataset.category !== 'all') btn.remove();
  });
  
  // Add category buttons
  categories.forEach(cat => {
    const btn = document.createElement('button');
    btn.className = 'category-btn';
    btn.dataset.category = cat;
    btn.textContent = cat;
    btn.onclick = () => filterByCategory(cat);
    filterDiv.appendChild(btn);
  });
}

function filterByCategory(category) {
  currentCategory = category;
  
  // Update active button
  document.querySelectorAll('.category-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.category === category);
  });
  
  renderVideoGrid();
}

function renderVideoGrid() {
  const grid = document.getElementById('videosGrid');
  const empty = document.getElementById('videosEmpty');
  
  // Filter videos
  const filtered = currentCategory === 'all' 
    ? currentVideos 
    : currentVideos.filter(v => v.category === currentCategory);
  
  if (filtered.length === 0) {
    hideEl('videosGrid');
    showEl('videosEmpty');
    return;
  }
  
  showEl('videosGrid');
  hideEl('videosEmpty');
  
  grid.innerHTML = filtered.map(video => `
    <div class="video-card" onclick="openVideoPlayer('${video.id}')">
      <div class="video-thumbnail">
        ${video.thumbnail_url ? `<img src="${video.thumbnail_url}" style="width:100%;height:100%;object-fit:cover;position:absolute;top:0;left:0;">` : ''}
      </div>
      <div class="video-info">
        <div class="video-title">${escapeHtml(video.title)}</div>
        ${video.description ? `<div class="video-description">${escapeHtml(video.description)}</div>` : ''}
        <div class="video-meta">
          ${video.category ? `<span class="video-category-badge">${escapeHtml(video.category)}</span>` : ''}
          ${video.duration ? `<span>⏱ ${escapeHtml(video.duration)}</span>` : ''}
          ${video.view_count ? `<span>👁 ${video.view_count} views</span>` : ''}
        </div>
      </div>
    </div>
  `).join('');
}

async function openVideoPlayer(videoId) {
  const supabase = initSupabase();
  const video = currentVideos.find(v => v.id === videoId);
  
  if (!video) return;
  
  // Get student ID for watermark
  const studentId = sessionStorage.getItem('studentId') || localStorage.getItem('studentId') || '';
  
  // Create secure player
  const playerHTML = VideoLibrary.createSecurePlayer(video.embed_url, video.title, studentId);
  
  // Inject into modal
  document.getElementById('videoPlayerContainer').innerHTML = playerHTML;
  document.getElementById('videoModalTitle').textContent = video.title;
  document.getElementById('videoModalDescription').textContent = video.description || '';
  
  // Show modal
  document.getElementById('videoPlayerModal').style.display = 'flex';
  
  // Increment view count
  await VideoLibrary.incrementViewCount(supabase, videoId);
}

function closeVideoPlayer() {
  document.getElementById('videoPlayerModal').style.display = 'none';
  document.getElementById('videoPlayerContainer').innerHTML = ''; // Stop video
}

function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

function showEl(id) { document.getElementById(id).style.display = 'block'; }
function hideEl(id) { document.getElementById(id).style.display = 'none'; }
</script>
```

---

## 📐 Step 6: Update View Switcher

### In `hub.html`, find the `showView()` function and add videos case:

```javascript
function showView(viewName) {
  // Hide all views
  document.querySelectorAll('.view').forEach(v => v.style.display = 'none');
  
  // Remove active state from all nav items
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  
  // Show selected view
  const view = document.getElementById(viewName + 'View');
  if (view) view.style.display = 'block';
  
  // Add view-specific class to body
  document.body.className = 'view-' + viewName;
  
  // Load data for specific views
  if (viewName === 'dashboard') {
    loadDashboard();
  } else if (viewName === 'grades') {
    loadGrades();
  } else if (viewName === 'notes') {
    loadNotes();
  } else if (viewName === 'videos') {  // ADD THIS
    loadStudentVideos();
  }
}
```

---

## 🎛️ Step 7: Admin Hub - Complete Implementation

The admin implementation is more complex. I'll create a separate complete admin video management page. Let me know if you want:

**Option A**: Standalone admin page (`admin-video-library.html`)
**Option B**: Integration into existing admin hub sidebar

For now, I'll create **Option A** which is cleaner and easier to manage.

---

## 🧪 Step 8: Testing Checklist

### Database Test:
```sql
-- Insert test video
INSERT INTO public.video_library (title, description, category, drive_url, embed_url, is_published)
VALUES (
  'Test Video - Vital Signs',
  'Learn how to measure blood pressure correctly',
  'Fundamentals',
  'https://drive.google.com/file/d/YOUR_FILE_ID/view',
  'https://drive.google.com/file/d/YOUR_FILE_ID/preview',
  true
);

-- Verify
SELECT * FROM video_library;
```

### Student Hub Test:
1. Open hub.html
2. Click "Video Library" in sidebar
3. Should see test video card
4. Click video → Player modal opens
5. Video should play with watermark
6. Right-click should be disabled

### Admin Test (once created):
1. Open admin video management
2. Add new video
3. Paste Google Drive link
4. Toggle publish
5. Video appears in student hub

---

## 📊 Next Steps

1. ✅ Run `ADD-VIDEO-LIBRARY-TABLE.sql` in Supabase
2. ✅ Set up Google Drive folder with proper permissions
3. ✅ Add `<script src="js/video-library.js"></script>` to hub.html
4. ✅ Add "Video Library" sidebar item to hub.html
5. ✅ Add video library view HTML to hub.html
6. ✅ Update `showView()` function
7. ⏳ Create admin management page (tell me if you want Option A or B)
8. ⏳ Upload test video to Google Drive
9. ⏳ Add test video via admin
10. ⏳ Test in student hub

---

## 🔒 Security Reminder

**What this setup provides:**
- View-only embedding
- Watermarked playback with student ID
- Right-click disabled
- No obvious download button
- Domain-restricted if using Google Workspace

**What this CANNOT prevent:**
- Screen recording (OS-level, can't be blocked)
- Network stream inspection (browser DevTools)
- Determined tech-savvy users

**For stricter protection**, migrate to Vimeo Pro, Wistia, or Cloudflare Stream with DRM.

---

## 📞 Support

If you encounter issues:
1. Check browser console for errors
2. Verify Supabase RLS policies are active
3. Confirm Google Drive sharing settings
4. Test with simple video first
5. Check that `js/video-library.js` is loaded

Ready to proceed? Let me know if you want me to create the admin management page next!
