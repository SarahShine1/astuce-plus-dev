import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Layout } from '../../components/Layout';
import { getAstuceDetails, getEvaluationDetails } from '../../services/dataService';
import { Astuce, EvaluationData } from '../../types';
import { ArrowLeft, CheckCircle, XCircle, AlertTriangle, Calendar, Award } from 'lucide-react';
import { COLORS } from '../../constants';

const ReadOnlyCriteria: React.FC<{ label: string; max: number; value: number }> = ({ label, max, value }) => (
    <div className="flex justify-between items-center py-2 border-b border-gray-50 last:border-0">
        <label className="text-sm font-medium text-gray-700 w-2/3">{label}</label>
        <div className="flex items-center gap-1">
            <span className={`font-mono font-bold ${value === max ? 'text-green-600' : 'text-gray-800'}`}>{value}</span>
            <span className="text-xs text-gray-400">/{max}</span>
        </div>
    </div>
);

export const EvaluationDetail: React.FC = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [astuce, setAstuce] = useState<Astuce | null>(null);
    const [evaluation, setEvaluation] = useState<EvaluationData | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (id) {
            const fetch = async () => {
                const astuceData = await getAstuceDetails(parseInt(id));
                const evalData = await getEvaluationDetails(parseInt(id));
                
                if (astuceData) setAstuce(astuceData);
                if (evalData) setEvaluation(evalData);
                setLoading(false);
            };
            fetch();
        }
    }, [id]);

    if (loading) return <Layout><div className="p-8 text-center text-gray-500">Chargement des détails...</div></Layout>;
    if (!astuce) return <Layout><div className="p-8 text-center text-red-500">Astuce introuvable.</div></Layout>;

    // Placeholder data if no evaluation record found (for demo resilience)
    const criteria = evaluation?.criteria || {
        methodologie: 0, reproductibilite: 0, standards: 0,
        cas_usage: 0, roi: 0, scalabilite: 0,
        risques: 0, mitigations: 0, conformite: 0,
        valeur_ajoutee: 0, originalite: 0,
        clarte: 0, completude: 0
    };
    
    const totalScore = evaluation?.totalScore || 0;
    
    const getStatusInfo = (status: string) => {
        if (status === 'validated') return { label: 'VALIDÉE', color: 'bg-green-100 text-green-700', icon: CheckCircle };
        if (status === 'changes_requested') return { label: 'MODIFICATIONS', color: 'bg-yellow-100 text-yellow-700', icon: AlertTriangle };
        return { label: 'REJETÉE', color: 'bg-red-100 text-red-700', icon: XCircle };
    };

    const statusInfo = getStatusInfo(astuce.status);
    const StatusIcon = statusInfo.icon;

    return (
        <Layout>
            <div className="flex items-center gap-4 mb-6">
                <button onClick={() => navigate('/expert/history')} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
                    <ArrowLeft size={20} className="text-gray-600" />
                </button>
                <div>
                    <div className="flex items-center gap-3">
                        <h1 className="text-xl font-bold text-[#053F5C]">Rapport d'évaluation #{astuce.id}</h1>
                        <span className={`px-2 py-0.5 rounded text-xs font-bold uppercase ${statusInfo.color}`}>{statusInfo.label}</span>
                    </div>
                    <div className="flex items-center gap-4 text-sm text-gray-500 mt-1">
                        <span>{astuce.title}</span>
                        {evaluation && (
                            <span className="flex items-center gap-1"><Calendar size={12}/> Évalué le {new Date(evaluation.date).toLocaleDateString()}</span>
                        )}
                    </div>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Score Summary Card (Top Priority) */}
                <div className="lg:col-span-1 lg:order-2">
                    <div className="bg-white rounded-xl shadow-lg border border-[#429EBD]/20 overflow-hidden">
                        <div className="bg-[#053F5C] p-6 text-center text-white relative">
                            <Award className="absolute top-4 right-4 opacity-20" size={48} />
                            <span className="text-sm uppercase tracking-widest opacity-80">Score Attribué</span>
                            <div className="text-5xl font-bold my-2">{totalScore}<span className="text-2xl opacity-60">/100</span></div>
                        </div>
                        <div className="p-6">
                            <div className={`flex items-center justify-center gap-3 p-4 rounded-lg mb-4 ${statusInfo.color}`}>
                                <StatusIcon size={24} />
                                <span className="font-bold tracking-wide text-lg">{statusInfo.label}</span>
                            </div>
                            <p className="text-center text-sm text-gray-500">Décision irrévocable enregistrée.</p>
                        </div>
                    </div>

                    {astuce.content_url && (
                         <div className="mt-6">
                            <h4 className="font-bold text-[#053F5C] mb-2">Média associé</h4>
                            <img src={astuce.content_url} alt="Content" className="w-full h-48 object-cover rounded-lg shadow-sm border border-gray-100" />
                         </div>
                    )}
                </div>

                {/* Detailed Criteria */}
                <div className="lg:col-span-2 lg:order-1 space-y-6">
                     <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 opacity-90">
                            <h4 className="font-bold text-[#429EBD] mb-3">Exactitude Scientifique</h4>
                            <ReadOnlyCriteria label="Méthodologie" max={10} value={criteria.methodologie} />
                            <ReadOnlyCriteria label="Reproductibilité" max={10} value={criteria.reproductibilite} />
                            <ReadOnlyCriteria label="Standards" max={10} value={criteria.standards} />
                        </div>
                        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 opacity-90">
                            <h4 className="font-bold text-[#429EBD] mb-3">Applicabilité</h4>
                            <ReadOnlyCriteria label="Cas d'usage" max={10} value={criteria.cas_usage} />
                            <ReadOnlyCriteria label="ROI / Rentabilité" max={8} value={criteria.roi} />
                            <ReadOnlyCriteria label="Scalabilité" max={7} value={criteria.scalabilite} />
                        </div>
                    </div>

                     <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 opacity-90">
                            <h4 className="font-bold text-[#429EBD] mb-3">Sécurité</h4>
                            <ReadOnlyCriteria label="Risques identifiés" max={8} value={criteria.risques} />
                            <ReadOnlyCriteria label="Mitigations" max={7} value={criteria.mitigations} />
                            <ReadOnlyCriteria label="Conformité" max={5} value={criteria.conformite} />
                        </div>
                        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 opacity-90">
                            <h4 className="font-bold text-[#429EBD] mb-3">Innovation</h4>
                            <ReadOnlyCriteria label="Valeur Ajoutée" max={8} value={criteria.valeur_ajoutee} />
                            <ReadOnlyCriteria label="Originalité" max={7} value={criteria.originalite} />
                        </div>
                    </div>

                     <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100 opacity-90">
                        <h4 className="font-bold text-[#429EBD] mb-3">Documentation</h4>
                        <ReadOnlyCriteria label="Clarté" max={5} value={criteria.clarte} />
                        <ReadOnlyCriteria label="Complétude" max={5} value={criteria.completude} />
                    </div>
                </div>
            </div>
        </Layout>
    );
};