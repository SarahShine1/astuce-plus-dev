import React, { useEffect, useState } from 'react';
import { Layout } from '../../components/Layout';
import { getReports, resolveReport, banUser } from '../../services/dataService';
import { Report } from '../../types';
import { ShieldAlert, Check, Ban, Filter } from 'lucide-react';

export const ReportList: React.FC = () => {
    const [reports, setReports] = useState<Report[]>([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState<'open' | 'resolved'>('open');

    useEffect(() => {
        loadReports();
    }, []);

    const loadReports = async () => {
        setLoading(true);
        const data = await getReports();
        setReports(data);
        setLoading(false);
    };

    const handleResolve = async (id: number) => {
        await resolveReport(id);
        setReports(prev => prev.map(r => r.id === id ? { ...r, status: 'resolved' } : r));
    };

    const handleBan = async (username: string) => {
        if(window.confirm(`Confirmer le bannissement de ${username} ?`)) {
            await banUser(username);
            alert(`Utilisateur ${username} banni.`);
        }
    };

    const filteredReports = reports.filter(r => r.status === filter);

    return (
        <Layout>
            <div className="mb-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-[#053F5C]">Centre des Signalements</h1>
                    <p className="text-gray-500">Traitez les alertes soumises par la communauté.</p>
                </div>
                
                <div className="flex bg-white rounded-lg p-1 shadow-sm border border-gray-200">
                    <button 
                        onClick={() => setFilter('open')}
                        className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${filter === 'open' ? 'bg-[#053F5C] text-white shadow-sm' : 'text-gray-500 hover:bg-gray-50'}`}
                    >
                        Ouverts
                    </button>
                    <button 
                        onClick={() => setFilter('resolved')}
                        className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${filter === 'resolved' ? 'bg-green-100 text-green-700 shadow-sm' : 'text-gray-500 hover:bg-gray-50'}`}
                    >
                        Résolus
                    </button>
                </div>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-gray-50 text-gray-500 text-xs uppercase font-semibold">
                        <tr>
                            <th className="px-6 py-3">Gravité</th>
                            <th className="px-6 py-3">Utilisateur</th>
                            <th className="px-6 py-3">Raison</th>
                            <th className="px-6 py-3">Date</th>
                            <th className="px-6 py-3 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {loading ? (
                             <tr><td colSpan={5} className="p-8 text-center text-gray-400">Chargement...</td></tr>
                        ) : filteredReports.length === 0 ? (
                            <tr><td colSpan={5} className="p-8 text-center text-gray-500">Aucun signalement dans cette catégorie.</td></tr>
                        ) : filteredReports.map((report) => (
                            <tr key={report.id} className="hover:bg-gray-50">
                                <td className="px-6 py-4">
                                     <span className={`px-2 py-1 rounded text-xs font-bold uppercase ${
                                        report.severity === 'high' ? 'bg-red-100 text-red-600' : 
                                        report.severity === 'medium' ? 'bg-orange-100 text-orange-600' : 
                                        'bg-blue-100 text-blue-600'
                                    }`}>
                                        {report.severity === 'high' ? 'Haute' : report.severity === 'medium' ? 'Moyenne' : 'Basse'}
                                    </span>
                                </td>
                                <td className="px-6 py-4 font-medium text-[#053F5C]">@{report.reported_user}</td>
                                <td className="px-6 py-4 text-gray-600">{report.reason}</td>
                                <td className="px-6 py-4 text-sm text-gray-500">{new Date(report.created_at).toLocaleDateString()}</td>
                                <td className="px-6 py-4 text-right flex justify-end gap-2">
                                    {report.status === 'open' && (
                                        <>
                                            <button 
                                                onClick={() => handleBan(report.reported_user)}
                                                className="p-2 bg-red-50 text-red-600 hover:bg-red-100 rounded-lg transition-colors"
                                                title="Bannir l'utilisateur"
                                            >
                                                <Ban size={16} />
                                            </button>
                                            <button 
                                                onClick={() => handleResolve(report.id)}
                                                className="p-2 bg-green-50 text-green-600 hover:bg-green-100 rounded-lg transition-colors"
                                                title="Marquer comme résolu"
                                            >
                                                <Check size={16} />
                                            </button>
                                        </>
                                    )}
                                    {report.status === 'resolved' && (
                                        <span className="text-xs text-gray-400 font-medium italic">Clôturé</span>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </Layout>
    );
};