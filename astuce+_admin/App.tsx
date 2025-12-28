import React from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Login } from './pages/Login';
import { ExpertDashboard } from './pages/expert/ExpertDashboard';
import { EvaluationForm } from './pages/expert/EvaluationForm';
import { EvaluationHistory } from './pages/expert/EvaluationHistory';
import { EvaluationDetail } from './pages/expert/EvaluationDetail';
import { ModeratorDashboard } from './pages/moderator/ModeratorDashboard';
import { UserList } from './pages/moderator/UserList';
import { CommentList } from './pages/moderator/CommentList';
import { ReportList } from './pages/moderator/ReportList';
import { AdminDashboard } from './pages/admin/AdminDashboard';
import { UserRole } from './types';
import { getCurrentUser } from './services/authService';

interface ProtectedRouteProps {
  children: React.ReactElement;
  allowedRole: UserRole;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children, allowedRole }) => {
  const user = getCurrentUser();

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  // Admin access bypass
  if (user.role === UserRole.ADMIN) {
      return children;
  }

  if (user.role !== allowedRole) {
    return <Navigate to="/login" replace />; 
  }

  return children;
};

const App: React.FC = () => {
  return (
    <HashRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        
        {/* Expert Routes */}
        <Route 
          path="/expert" 
          element={
            <ProtectedRoute allowedRole={UserRole.EXPERT}>
              <ExpertDashboard />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/expert/evaluate/:id" 
          element={
            <ProtectedRoute allowedRole={UserRole.EXPERT}>
              <EvaluationForm />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/expert/history" 
          element={
            <ProtectedRoute allowedRole={UserRole.EXPERT}>
              <EvaluationHistory />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/expert/history/:id" 
          element={
            <ProtectedRoute allowedRole={UserRole.EXPERT}>
              <EvaluationDetail />
            </ProtectedRoute>
          } 
        />

        {/* Moderator Routes */}
        <Route 
          path="/moderator" 
          element={
            <ProtectedRoute allowedRole={UserRole.MODERATOR}>
              <ModeratorDashboard />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/moderator/users" 
          element={
            <ProtectedRoute allowedRole={UserRole.MODERATOR}>
              <UserList />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/moderator/comments" 
          element={
            <ProtectedRoute allowedRole={UserRole.MODERATOR}>
              <CommentList />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/moderator/reports" 
          element={
            <ProtectedRoute allowedRole={UserRole.MODERATOR}>
              <ReportList />
            </ProtectedRoute>
          } 
        />
        
        {/* Admin Routes */}
        <Route 
          path="/admin" 
          element={
            <ProtectedRoute allowedRole={UserRole.ADMIN}>
              <AdminDashboard />
            </ProtectedRoute>
          } 
        />

        {/* Fallback */}
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </HashRouter>
  );
};

export default App;