import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Layout } from '../../components/Layout';
import { StatCard } from '../../components/StatCard';
import { getAssignedAstuces } from '../../services/dataService';
import { getCurrentUser } from '../../services/authService';
import { Astuce } from '../../types';
import { ListChecks, Clock, CheckCircle2, ArrowRight } from 'lucide-react';
import { COLORS } from '../../constants';

export const ExpertDashboard: React.FC = () => {
  const [astuces, setAstuces] = useState<Astuce[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const user = getCurrentUser();

  useEffect(() => {
    const fetch = async () => {
      if (user) {
        const data = await getAssignedAstuces(user.id);
        setAstuces(data);
        setLoading(false);
      }
    };
    fetch();
  }, [user]);

  // Calculations for dashboard
  const pendingCount = astuces.filter(a => a.status === 'assigned').length;
  const validatedCount = astuces.filter(a => a.status === 'validated').length;

  return (
    <Layout>
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-[#053F5C]">Tableau de Bord Expert</h1>
        <p className="text-gray-500">Bienvenue, {user?.first_name}. Vous avez {pendingCount} astuce(s) à évaluer.</p>
      </div>

      {/* Stats Row */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <StatCard title="À évaluer" value={pendingCount} icon={Clock} color="text-[#F7AD19]" />
        <StatCard title="Validées ce mois" value={validatedCount} icon={CheckCircle2} color="text-[#10B981]" trend="+12% vs mois dernier" />
        <StatCard title="Total Traitées" value={astuces.length + 15} icon={ListChecks} />
      </div>

      {/* Task List */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
          <h2 className="text-lg font-bold text-[#053F5C]">File d'attente prioritaire</h2>
          <span className="text-xs font-medium px-2.5 py-1 bg-blue-50 text-blue-700 rounded-full">
            Algorithme d'attribution actif
          </span>
        </div>

        {loading ? (
          <div className="p-8 text-center text-gray-400">Chargement...</div>
        ) : astuces.length === 0 ? (
            <div className="p-12 text-center">
                <div className="inline-block p-4 rounded-full bg-green-50 mb-4">
                    <CheckCircle2 size={32} className="text-green-600" />
                </div>
                <h3 className="text-lg font-medium text-gray-900">Tout est à jour !</h3>
                <p className="text-gray-500">Aucune astuce en attente pour le moment.</p>
            </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead className="bg-gray-50 text-gray-500 text-xs uppercase font-semibold">
                <tr>
                  <th className="px-6 py-3">Titre</th>
                  <th className="px-6 py-3">Catégorie</th>
                  <th className="px-6 py-3">Auteur</th>
                  <th className="px-6 py-3">Date</th>
                  <th className="px-6 py-3 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {astuces.map((astuce) => (
                  <tr key={astuce.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="font-medium text-[#053F5C]">{astuce.title}</div>
                      <div className="text-xs text-gray-400 truncate max-w-xs">{astuce.description}</div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-50 text-blue-800">
                        {astuce.category}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">@{astuce.author}</td>
                    <td className="px-6 py-4 text-sm text-gray-600">{new Date(astuce.created_at).toLocaleDateString()}</td>
                    <td className="px-6 py-4 text-right">
                      {astuce.status === 'assigned' ? (
                         <button 
                         onClick={() => navigate(`/expert/evaluate/${astuce.id}`)}
                         className="inline-flex items-center gap-1 px-3 py-1.5 bg-[#429EBD] hover:bg-[#053F5C] text-white text-sm font-medium rounded-lg transition-colors"
                       >
                         Évaluer <ArrowRight size={14} />
                       </button>
                      ) : (
                        <span className="text-xs text-gray-400 font-medium px-3 py-1 bg-gray-100 rounded-full">
                            Déjà traité
                        </span>
                      )}
                     
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </Layout>
  );
};