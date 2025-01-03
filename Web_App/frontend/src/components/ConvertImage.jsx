import { useState } from "react";

const Header = () => (
  <header className="bg-primary text-white text-center p-3">
    <h1>Image Converter App</h1>
    <p>Convert your images easily and quickly!</p>
  </header>
);

const Footer = () => (
  <footer className="bg-dark text-white text-center p-3 mt-4">
    <p>
      &copy; {new Date().getFullYear()} Image Converter. All rights reserved.
    </p>
  </footer>
);

const ImageConverter = () => {
  const [image, setImage] = useState(null);
  const [format, setFormat] = useState("png"); // Default format
  const [convertedImage, setConvertedImage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false); // Loading state

  // Handle image upload and ensure only image files are accepted
  const handleImageUpload = (e) => {
    const file = e.target.files[0];
    if (file && (file.type === "image/png" || file.type === "image/jpeg")) {
      setImage(file);
      setConvertedImage(""); // Reset converted image when a new image is uploaded
      setError(""); // Reset error message
    } else {
      setError("Please upload a valid PNG or JPEG image.");
    }
  };

  // Handle format selection
  const handleFormatChange = (e) => {
    setFormat(e.target.value);
  };

  // Handle the image conversion
  const handleConvert = async () => {
    if (!image) {
      setError("Please upload an image before converting.");
      return;
    }

    setLoading(true); // Set loading state when conversion starts

    const formData = new FormData();
    formData.append("image", image);
    formData.append("format", format);

    try {
      const response = await fetch("http://127.0.0.1:8000/api/convert-image/", {
        method: "POST",
        body: formData,
      });

      if (!response.ok) {
        const errorMessage = await response.text(); // Get the error message from response
        throw new Error(`Network response was not ok: ${errorMessage}`);
      }

      const data = await response.json();
      const fullImageUrl = `http://127.0.0.1:8000${data.converted_image_url}`;
      setConvertedImage(fullImageUrl);
      setLoading(false); // Stop loading when response is received
    } catch (err) {
      setLoading(false); // Stop loading if an error occurs
      setError("Failed to convert image. Please try again.");
      console.error(err);
    }
  };

  // New download function
  const handleDownload = async () => {
    if (!convertedImage) return;

    try {
      const response = await fetch(convertedImage);

      if (!response.ok) {
        throw new Error("Failed to fetch the converted image");
      }

      const blob = await response.blob(); // Get the image as a Blob
      const url = window.URL.createObjectURL(blob); // Create a temporary URL for the Blob

      const a = document.createElement("a"); // Create an anchor element
      a.href = url; // Set the URL to the Blob
      a.download = `converted-image.${format}`; // Set the download filename
      document.body.appendChild(a); // Append the anchor to the body
      a.click(); // Trigger the download
      a.remove(); // Clean up
      window.URL.revokeObjectURL(url); // Free up memory
    } catch (error) {
      console.error("Error downloading image:", error);
    }
  };

  return (
    <div className="container mt-5">
      <Header />

      <h2 className="text-center mb-4">Image Converter</h2>

      {/* Display error message */}
      {error && <div className="alert alert-danger">{error}</div>}

      {/* File upload input */}
      <div className="mb-3">
        <input
          type="file"
          accept="image/png, image/jpeg"
          onChange={handleImageUpload}
          className="form-control"
        />
      </div>

      {/* Format selection and convert button, shown when an image is uploaded */}
      {image && (
        <div className="mb-4">
          <label htmlFor="format" className="form-label">
            Choose format:
          </label>
          <select
            id="format"
            value={format}
            onChange={handleFormatChange}
            className="form-select mb-3"
          >
            <option value="png">PNG</option>
            <option value="jpg">JPG</option>
            <option value="jpeg">JPEG</option>
          </select>

          <button className="btn btn-primary w-100" onClick={handleConvert}>
            {loading ? "Converting..." : "Convert"}
          </button>
        </div>
      )}

      {/* Display the converted image */}
      {convertedImage && (
        <div className="mt-4 text-center">
          <h4>Converted Image:</h4>
          <img
            src={convertedImage}
            alt="Converted"
            className="img-fluid rounded mt-2"
            style={{ maxWidth: "100%", height: "auto" }}
          />
          <div className="mt-2">
            <button onClick={handleDownload} className="btn btn-success">
              Download Image
            </button>
          </div>
        </div>
      )}

      <Footer />
    </div>
  );
};

export default ImageConverter;
