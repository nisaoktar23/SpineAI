import axios from 'axios';

const API_BASE_URL = 'http://124.243.177.173:8080/api';

/**
 * Create a new spine analysis
 */
export const createAnalysis = async (imageFile, token) => {
  try {
    const formData = new FormData();
    formData.append('image', imageFile);

    const response = await axios.post(`${API_BASE_URL}/analyses`, formData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'multipart/form-data'
      },
      timeout: 60000
    });

    return response.data;
  } catch (error) {
    console.error('❌ Backend spine analysis failed:', error.message);
    throw error;
  }
};

/**
 * Create a new posture analysis
 */
export const createPostureAnalysis = async (imageFile, token) => {
  try {
    const formData = new FormData();
    formData.append('image', imageFile);

    const response = await axios.post(`${API_BASE_URL}/analyses/posture`, formData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'multipart/form-data'
      },
      timeout: 60000
    });

    return response.data;
  } catch (error) {
    console.error('❌ Backend posture analysis failed:', error.message);
    throw error;
  }
};

/**
 * Get user's analysis history
 */
export const getUserAnalyses = async (token, page = 1, limit = 10) => {
  try {
    const response = await axios.get(`${API_BASE_URL}/analyses`, {
      params: { page, limit },
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return response.data;
  } catch (error) {
    console.warn('Failed to fetch analyses:', error.message);
    return { success: true, data: { analyses: [], total: 0, page: 1, pages: 0 } };
  }
};

/**
 * Get analysis by ID
 */
export const getAnalysisById = async (analysisId, token) => {
  try {
    const response = await axios.get(`${API_BASE_URL}/analyses/${analysisId}`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return response.data;
  } catch (error) {
    console.error('Failed to fetch analysis:', error);
    throw error;
  }
};

/**
 * Get analysis statistics
 */
export const getAnalysisStats = async (token) => {
  try {
    const response = await axios.get(`${API_BASE_URL}/analyses/stats`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return response.data;
  } catch (error) {
    console.warn('Failed to fetch stats:', error.message);
    return { success: true, data: { totalAnalyses: 0, averageScore: 0, latestResult: 'N/A' } };
  }
};

/**
 * Delete analysis
 */
export const deleteAnalysis = async (analysisId, token) => {
  try {
    const response = await axios.delete(`${API_BASE_URL}/analyses/${analysisId}`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return response.data;
  } catch (error) {
    console.error('Failed to delete analysis:', error);
    throw error;
  }
};
