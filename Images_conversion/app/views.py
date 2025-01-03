from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from PIL import Image
import os
from .serializers import ImageUploadSerializer


class ConvertImageView(APIView):
    def post(self, request, format=None):
        serializer = ImageUploadSerializer(data=request.data)
        
        if serializer.is_valid():
            image = serializer.validated_data['image']
            image_name = default_storage.save(image.name, ContentFile(image.read()))
            image_path = os.path.join(default_storage.location, image_name)

            try:
                with Image.open(image_path) as img:
                    new_format = request.data.get('format', 'png').lower()

                    # Map 'jpg' to 'jpeg'
                    if new_format == 'jpg':
                        new_format = 'jpeg'

                    valid_formats = ['png', 'jpeg']  # Accept 'jpeg' and 'png' as valid formats
                    if new_format not in valid_formats:
                        return Response({'error': f'Unsupported format: {new_format}'}, status=status.HTTP_400_BAD_REQUEST)

                    if new_format == 'jpeg':
                        img = img.convert('RGB')  # Ensure conversion to RGB for JPEG

                    new_image_name = f"{os.path.splitext(image_name)[0]}.{new_format}"
                    new_image_path = os.path.join(default_storage.location, new_image_name)
                    img.save(new_image_path, new_format.upper())

                    new_image_url = default_storage.url(new_image_name)
                    return Response({'converted_image_url': new_image_url}, status=status.HTTP_200_OK)

            except Exception as e:
                print(f"Image conversion error: {str(e)}")
                return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        print("Serializer errors:", serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
