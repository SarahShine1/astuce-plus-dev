import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Layout } from '../../components/Layout';
import { getAstuceDetails, submitEvaluation } from '../../services/dataService';
import { Astuce, EvaluationCriteria } from '../../types';
import { ArrowLeft, Save, AlertTriangle, CheckCircle, XCircle } from 'lucide-react';
import { COLORS, PASSING_SCORE, MODIFICATION_SCORE_MIN, MODIFICATION_SCORE_MAX } from '../../constants';

const CriteriaInput: React.FC<{ 
    label: string; 
    max: number; 
    value: number; 
    onChange: (val: number) => void 
}> = ({ label, max, value, onChange }) => (
    <div className="flex justify-between items-center py-2 border-b border-gray-50 last:border-0">
        <label className="text-sm font-medium text-gray-700 w-2/3">{label}</label>
        <div className="flex items-center gap-2">
            <input 
                type="number" 
                min="0" 
                max={max} 
                value={value} 
                onChange={(e) => {
                    const val = Math.min(max, Math.max(0, parseInt(e.target.value) || 0));
                    onChange(val);
                }}
                className="w-16 p-1 border border-gray-300 rounded text-center text-sm font-mono focus:ring-1 focus:ring-[#429EBD]"
            />
            <span className="text-xs text-gray-400 w-8">/{max}</span>
        </div>
    </div>
);

export const EvaluationForm: React.FC = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [astuce, setAstuce] = useState<Astuce | null>(null);
    const [criteria, setCriteria] = useState<EvaluationCriteria>({
        methodologie: 0, reproductibilite: 0, standards: 0,
        cas_usage: 0, roi: 0, scalabilite: 0,
        risques: 0, mitigations: 0, conformite: 0,
        valeur_ajoutee: 0, originalite: 0,
        clarte: 0, completude: 0
    });
    const [totalScore, setTotalScore] = useState(0);

    useEffect(() => {
        if (id) {
            getAstuceDetails(parseInt(id)).then(data => {
                if (data) setAstuce(data);
            });
        }
    }, [id]);

    useEffect(() => {
        // Calculate Total
        const total = (Object.values(criteria) as number[]).reduce((a, b) => a + b, 0);
        setTotalScore(total);
    }, [criteria]);

    const handleCriteriaChange = (key: keyof EvaluationCriteria, value: number) => {
        setCriteria(prev => ({ ...prev, [key]: value }));
    };

    const getDecisionStatus = () => {
        if (totalScore >= PASSING_SCORE) return { label: 'VALIDATION', color: 'bg-green-100 text-green-700', icon: CheckCircle };
        if (totalScore >= MODIFICATION_SCORE_MIN && totalScore <= MODIFICATION_SCORE_MAX) return { label: 'MODIFICATIONS', color: 'bg-yellow-100 text-yellow-700', icon: AlertTriangle };
        return { label: 'REJET', color: 'bg-red-100 text-red-700', icon: XCircle };
    };

    const handleSubmit = async () => {
        if (!astuce) return;
        const decision = totalScore >= PASSING_SCORE ? 'validated' : (totalScore >= MODIFICATION_SCORE_MIN ? 'changes_requested' : 'rejected');
        await submitEvaluation(astuce.id, totalScore, criteria, decision);
        navigate('/expert');
    };

    const status = getDecisionStatus();
    const StatusIcon = status.icon;

    if (!astuce) return <Layout>Chargement...</Layout>;

    return (
        <Layout>
            <div className="flex items-center gap-4 mb-6">
                <button onClick={() => navigate('/expert')} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
                    <ArrowLeft size={20} className="text-gray-600" />
                </button>
                <div>
                    <h1 className="text-xl font-bold text-[#053F5C]">Évaluation de l'astuce #{astuce.id}</h1>
                    <p className="text-sm text-gray-500">{astuce.title}</p>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column: Astuce Details */}
                <div className="lg:col-span-2 space-y-6">
                    <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                        <h3 className="font-bold text-[#053F5C] mb-4 border-b pb-2">Contenu de l'astuce</h3>
                        {astuce.content_url && (
                             <img src={astuce.content_url} alt="Content" className="w-full h-64 object-cover rounded-lg mb-4" />
                        )}
                        <p className="text-gray-700 leading-relaxed whitespace-pre-line">{astuce.description}</p>
                        <div className="mt-4 pt-4 border-t flex gap-4 text-sm text-gray-500">
                            <span>Catégorie: <strong className="text-gray-800">{astuce.category}</strong></span>
                            <span>Auteur: <strong className="text-gray-800">@{astuce.author}</strong></span>
                        </div>
                    </div>

                    {/* Scientific & Applicability */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
                            <h4 className="font-bold text-[#429EBD] mb-3">Exactitude Scientifique (30)</h4>
                            <CriteriaInput label="Méthodologie" max={10} value={criteria.methodologie} onChange={(v) => handleCriteriaChange('methodologie', v)} />
                            <CriteriaInput label="Reproductibilité" max={10} value={criteria.reproductibilite} onChange={(v) => handleCriteriaChange('reproductibilite', v)} />
                            <CriteriaInput label="Standards" max={10} value={criteria.standards} onChange={(v) => handleCriteriaChange('standards', v)} />
                        </div>
                        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
                            <h4 className="font-bold text-[#429EBD] mb-3">Applicabilité (25)</h4>
                            <CriteriaInput label="Cas d'usage" max={10} value={criteria.cas_usage} onChange={(v) => handleCriteriaChange('cas_usage', v)} />
                            <CriteriaInput label="ROI / Rentabilité" max={8} value={criteria.roi} onChange={(v) => handleCriteriaChange('roi', v)} />
                            <CriteriaInput label="Scalabilité" max={7} value={criteria.scalabilite} onChange={(v) => handleCriteriaChange('scalabilite', v)} />
                        </div>
                    </div>

                     {/* Security & Innovation */}
                     <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
                            <h4 className="font-bold text-[#429EBD] mb-3">Sécurité (20)</h4>
                            <CriteriaInput label="Risques identifiés" max={8} value={criteria.risques} onChange={(v) => handleCriteriaChange('risques', v)} />
                            <CriteriaInput label="Mitigations" max={7} value={criteria.mitigations} onChange={(v) => handleCriteriaChange('mitigations', v)} />
                            <CriteriaInput label="Conformité" max={5} value={criteria.conformite} onChange={(v) => handleCriteriaChange('conformite', v)} />
                        </div>
                        <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
                            <h4 className="font-bold text-[#429EBD] mb-3">Innovation (15)</h4>
                            <CriteriaInput label="Valeur Ajoutée" max={8} value={criteria.valeur_ajoutee} onChange={(v) => handleCriteriaChange('valeur_ajoutee', v)} />
                            <CriteriaInput label="Originalité" max={7} value={criteria.originalite} onChange={(v) => handleCriteriaChange('originalite', v)} />
                        </div>
                    </div>

                     {/* Documentation */}
                     <div className="bg-white p-5 rounded-xl shadow-sm border border-gray-100">
                        <h4 className="font-bold text-[#429EBD] mb-3">Documentation (10)</h4>
                        <CriteriaInput label="Clarté" max={5} value={criteria.clarte} onChange={(v) => handleCriteriaChange('clarte', v)} />
                        <CriteriaInput label="Complétude" max={5} value={criteria.completude} onChange={(v) => handleCriteriaChange('completude', v)} />
                    </div>
                </div>

                {/* Right Column: Scoring Summary (Sticky) */}
                <div className="lg:col-span-1">
                    <div className="sticky top-8 bg-white rounded-xl shadow-lg border border-[#429EBD]/20 overflow-hidden">
                        <div className="bg-[#053F5C] p-6 text-center text-white">
                            <span className="text-sm uppercase tracking-widest opacity-80">Score Final</span>
                            <div className="text-5xl font-bold my-2">{totalScore}<span className="text-2xl opacity-60">/100</span></div>
                        </div>
                        
                        <div className="p-6">
                            <div className={`flex items-center gap-3 p-4 rounded-lg mb-6 ${status.color}`}>
                                <StatusIcon size={24} />
                                <span className="font-bold tracking-wide">{status.label}</span>
                            </div>

                            <div className="space-y-4 text-sm text-gray-600 mb-8">
                                <div className="flex justify-between">
                                    <span>Validation</span>
                                    <span className="font-medium text-green-600">≥ 80</span>
                                </div>
                                <div className="flex justify-between">
                                    <span>Modifications</span>
                                    <span className="font-medium text-yellow-600">60 - 79</span>
                                </div>
                                <div className="flex justify-between">
                                    <span>Rejet</span>
                                    <span className="font-medium text-red-600">&lt; 60</span>
                                </div>
                            </div>

                            <button 
                                onClick={handleSubmit}
                                className="w-full py-4 bg-[#F7AD19] hover:bg-amber-500 text-[#053F5C] font-bold rounded-lg transition-all shadow-sm flex items-center justify-center gap-2"
                            >
                                <Save size={20} />
                                Confirmer la décision
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </Layout>
    );
};