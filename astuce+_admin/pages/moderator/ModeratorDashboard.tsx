import React, { useEffect, useState } from 'react';
import { Layout } from '../../components/Layout';
import { StatCard } from '../../components/StatCard';
import { getReports, banUser } from '../../services/dataService';
import { Report } from '../../types';
import { Shield, AlertTriangle, UserX, MessageSquareWarning, Check } from 'lucide-react';
import { getCurrentUser } from '../../services/authService';

export const ModeratorDashboard: React.FC = () => {
  const [reports, setReports] = useState<Report[]>([]);
  const user = getCurrentUser();

  useEffect(() => {
    getReports().then(setReports);
  }, []);

  const handleBan = async (username: string) => {
    if(window.confirm(`Voulez-vous vraiment bannir ${username} ?`)) {
        await banUser(username);
        alert(`Utilisateur ${username} banni.`);
        // Refresh list logic here...
    }
  };

  const openReports = reports.filter(r => r.status === 'open');
  const highSeverity = openReports.filter(r => r.severity === 'high').length;

  return (
    <Layout>
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-[#053F5C]">Dashboard Modération</h1>
        <p className="text-gray-500">Supervision communautaire et gestion des signalements.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <StatCard title="Signalements Ouverts" value={openReports.length} icon={Shield} color="text-blue-600" />
        <StatCard title="Priorité Haute" value={highSeverity} icon={AlertTriangle} color="text-red-600" />
        <StatCard title="Actions ce mois" value="142" icon={UserX} />
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100">
        <div className="px-6 py-4 border-b border-gray-100 bg-gray-50 rounded-t-xl">
            <h2 className="font-bold text-[#053F5C] flex items-center gap-2">
                <MessageSquareWarning size={20} />
                Signalements Récents
            </h2>
        </div>
        
        <div className="overflow-x-auto">
            <table className="w-full text-left">
                <thead className="text-xs text-gray-400 uppercase bg-gray-50 border-b">
                    <tr>
                        <th className="px-6 py-3">Utilisateur</th>
                        <th className="px-6 py-3">Raison</th>
                        <th className="px-6 py-3">Gravité</th>
                        <th className="px-6 py-3">Date</th>
                        <th className="px-6 py-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                    {reports.map((report) => (
                        <tr key={report.id} className="hover:bg-gray-50">
                            <td className="px-6 py-4 font-medium text-[#053F5C]">@{report.reported_user}</td>
                            <td className="px-6 py-4 text-gray-600">{report.reason}</td>
                            <td className="px-6 py-4">
                                <span className={`px-2 py-1 rounded text-xs font-bold uppercase ${
                                    report.severity === 'high' ? 'bg-red-100 text-red-600' : 
                                    report.severity === 'medium' ? 'bg-orange-100 text-orange-600' : 
                                    'bg-blue-100 text-blue-600'
                                }`}>
                                    {report.severity}
                                </span>
                            </td>
                            <td className="px-6 py-4 text-sm text-gray-500">{new Date(report.created_at).toLocaleDateString()}</td>
                            <td className="px-6 py-4 text-right flex justify-end gap-2">
                                <button 
                                    onClick={() => handleBan(report.reported_user)}
                                    className="px-3 py-1 bg-red-50 text-red-600 text-xs font-bold rounded hover:bg-red-100"
                                >
                                    BANNIR
                                </button>
                                <button className="px-3 py-1 bg-green-50 text-green-600 text-xs font-bold rounded hover:bg-green-100 flex items-center gap-1">
                                    <Check size={12} /> RÉSOUDRE
                                </button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
      </div>
    </Layout>
  );
};