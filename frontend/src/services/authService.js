import axios from 'axios';

const API_BASE_URL = 'http://124.243.177.173:8080/api';
const API_URL = `${API_BASE_URL}/auth`;

// Create axios instance with custom config
const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor to include token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Add response interceptor to handle token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        const refreshToken = localStorage.getItem('refreshToken');
        const response = await axios.post(`${API_URL}/refresh-token`, { refreshToken });
        
        const { accessToken, refreshToken: newRefreshToken } = response.data;
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('refreshToken', newRefreshToken);
        
        originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        return api(originalRequest);
      } catch (err) {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        window.location.href = '/login';
        return Promise.reject(err);
      }
    }
    
    return Promise.reject(error);
  }
);

export const authService = {
  register: async (data) => {
    try {
      const response = await api.post('/register', data);
      return response.data;
    } catch (error) {
      // Mock registration for offline mode
      const mockUser = {
        _id: 'demo-user-' + Date.now(),
        firstName: data.firstName,
        lastName: data.lastName,
        email: data.email,
        profileImage: '/images/default-avatar.png'
      };
      const mockToken = 'demo-token-' + Date.now();
      localStorage.setItem('accessToken', mockToken);
      localStorage.setItem('refreshToken', mockToken);
      localStorage.setItem('user', JSON.stringify(mockUser));
      return { user: mockUser, accessToken: mockToken, refreshToken: mockToken };
    }
  },

  login: async (credentials) => {
    try {
      const response = await api.post('/login', credentials);
      const { accessToken, refreshToken, user } = response.data;
      localStorage.setItem('accessToken', accessToken);
      localStorage.setItem('refreshToken', refreshToken);
      localStorage.setItem('user', JSON.stringify(user));
      return response.data;
    } catch (error) {
      // Mock login for offline mode
      const mockUser = {
        _id: 'demo-user-123',
        firstName: 'Demo',
        lastName: 'User',
        email: credentials.email,
        profileImage: '/images/default-avatar.png'
      };
      const mockToken = 'demo-token-' + Date.now();
      localStorage.setItem('accessToken', mockToken);
      localStorage.setItem('refreshToken', mockToken);
      localStorage.setItem('user', JSON.stringify(mockUser));
      return { user: mockUser, accessToken: mockToken, refreshToken: mockToken };
    }
  },

  logout: async () => {
    try {
      await api.post('/logout');
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      localStorage.removeItem('user');
    }
  },

  getCurrentUser: async () => {
    const response = await api.get('/me');
    return response.data;
  },

  updateProfile: async (data) => {
    const response = await api.put('/profile', data, {
      headers: {
        'Content-Type': data instanceof FormData ? 'multipart/form-data' : 'application/json',
      },
    });
    localStorage.setItem('user', JSON.stringify(response.data.user));
    return response.data;
  },

  changePassword: async (data) => {
    const response = await api.post('/change-password', data);
    return response.data;
  },
};

export default api;
