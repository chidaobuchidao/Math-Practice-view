import request from '@/utils/request'

export const uploadApi = {
  // 上传图片
  uploadImage(file) {
    const formData = new FormData()
    formData.append('file', file)
    return request.post('/api/upload/image', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
  },

  // 删除图片
  deleteImage(imageUrl) {
    return request.delete('/api/upload/image', {
      params: { url: imageUrl }
    })
  }
}

