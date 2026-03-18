# images/ — Placeholder images and upload instructions

Folder layout:
- images/
  - factory/
  - innovation/
  - bootcamp/
  - education/
  - healthcare/
  - real-estate/
  - README.md

Recommended image guidelines
- Hero / carousel images: 1200 x 800 px (landscape), JPG or PNG or optimized SVG.
- Thumbnails: 400 x 300 px.
- File format: JPG/PNG for photos; SVG acceptable for placeholders/illustrations.
- Filenames: image1.jpg, image2.jpg, image3.jpg (or .svg) inside each project folder.
- Use descriptive alternative text in the HTML alt attribute for accessibility.

How to replace placeholders (GitHub web UI)
1. Navigate to the target folder, e.g., images/factory/.
2. Click "Add file" → "Upload files".
3. Drag and drop your images, keeping the same filenames (image1.jpg, image2.jpg, image3.jpg) to preserve carousel paths.
4. Commit with a clear message, e.g., "Replace placeholders for factory project images".

How to replace placeholders (Git + CLI)
1. In your local repo root:
   git checkout main
   mkdir -p images/factory images/innovation images/bootcamp images/education images/healthcare images/real-estate
2. Copy your images into the appropriate directories and ensure filenames match the HTML paths (e.g., images/factory/image1.jpg).
3. Stage and commit:
   git add images/
   git commit -m "Add real project images for carousels"
   git push origin main

Updating HTML if you change filenames
- If you change filenames, update the image src paths in the relevant HTML pages (e.g., factory.html) accordingly.

Image optimization tips
- Compress JPEGs with 70–80% quality for faster load.
- Resize large images to recommended dimensions before uploading.
- Consider using a CDN for production images.