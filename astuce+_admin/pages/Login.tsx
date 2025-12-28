import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Lock, Mail, Loader2 } from 'lucide-react';
import { login } from '../services/authService';
import { COLORS } from '../constants';
import { UserRole } from '../types';

export const Login: React.FC = () => {
  const [email, setEmail] = useState('expert@astuce.com');
  const [password, setPassword] = useState('password');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await login(email, password);
      localStorage.setItem('token', response.access);
      localStorage.setItem('user', JSON.stringify(response.user));

      // Redirect based on role
      switch (response.user.role) {
        case UserRole.EXPERT:
          navigate('/expert');
          break;
        case UserRole.MODERATOR:
          navigate('/moderator');
          break;
        case UserRole.ADMIN:
          navigate('/admin');
          break;
        default:
          setError("Rôle non autorisé pour ce portail.");
      }
    } catch (err) {
      setError('Email ou mot de passe incorrect.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#F8F9FA]">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl overflow-hidden">
        <div className="p-8 pb-6 bg-[#053F5C] text-center">
          <div className="w-16 h-16 mx-auto bg-[#F7AD19] rounded-xl flex items-center justify-center mb-4">
             <span className="text-3xl font-bold text-[#053F5C]">A+</span>
          </div>
          <h2 className="text-2xl font-bold text-white">Portail Staff</h2>
          <p className="text-[#429EBD] text-sm mt-1">Experts & Modérateurs uniquement</p>
        </div>

        <div className="p-8">
          <form onSubmit={handleSubmit} className="space-y-6">
            {error && (
              <div className="p-3 rounded bg-red-50 border border-red-200 text-red-600 text-sm text-center">
                {error}
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Email professionnel</label>
              <div className="relative">
                <Mail className="absolute left-3 top-3 text-gray-400" size={18} />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#429EBD] focus:border-transparent outline-none transition-all"
                  placeholder="nom@astuce.com"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Mot de passe</label>
              <div className="relative">
                <Lock className="absolute left-3 top-3 text-gray-400" size={18} />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#429EBD] focus:border-transparent outline-none transition-all"
                  placeholder="••••••••"
                  required
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 px-4 bg-[#053F5C] hover:bg-[#04334a] text-white font-medium rounded-lg transition-colors flex items-center justify-center gap-2 disabled:opacity-70"
            >
              {loading ? <Loader2 className="animate-spin" size={20} /> : 'Se connecter'}
            </button>
            
            <div className="text-center text-xs text-gray-500 mt-4">
               Démo: expert@astuce.com ou mod@astuce.com<br/>(mdp: n'importe)
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};