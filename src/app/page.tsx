import Link from 'next/link';

const modules = [
  ['Payments', 'Actual outgoing transactions', 'Planned'],
  ['Receipts', 'Actual incoming transactions', 'Planned'],
  ['Debtors', 'Customer invoices and collections', 'Planned'],
  ['Creditors', 'Supplier bills and settlements', 'Planned'],
  ['Cash & Banks', 'Separate account-wise balances', 'Foundation'],
  ['Approvals', 'Maker-checker transaction workflow', 'Planned'],
];

export default function HomePage() {
  return (
    <main style={{maxWidth:1120, margin:'0 auto', padding:'40px 22px'}}>
      <header style={{display:'flex',justifyContent:'space-between',alignItems:'center',gap:16,flexWrap:'wrap'}}>
        <div>
          <div style={{fontSize:12,fontWeight:700,letterSpacing:2,color:'#64748b'}}>OVERSEAS INFRASTRUCTURE</div>
          <h1 style={{fontSize:32,margin:'8px 0'}}>Finance Control Centre</h1>
          <p style={{color:'#64748b',margin:0}}>Phase 1 foundation · Database-first finance platform</p>
        </div>
        <Link href="/login" style={{background:'#14213d',color:'white',padding:'12px 18px',borderRadius:10,fontWeight:700}}>Sign in</Link>
      </header>
      <section style={{marginTop:32,padding:24,background:'#14213d',color:'white',borderRadius:18}}>
        <div style={{fontSize:12,opacity:.75}}>PROJECT STATUS</div>
        <h2 style={{fontSize:24,margin:'8px 0'}}>Secure foundation scaffold created</h2>
        <p style={{maxWidth:760,lineHeight:1.6,opacity:.85}}>The initial project structure and database foundation are ready. Live balances and transactions will appear only after the database is configured and real company entries are recorded. No sample financial figures are fabricated.</p>
      </section>
      <h2 style={{marginTop:34,fontSize:20}}>Finance modules</h2>
      <div style={{display:'grid',gridTemplateColumns:'repeat(auto-fit,minmax(230px,1fr))',gap:14}}>
        {modules.map(([name,desc,status]) => <article key={name} style={{background:'white',padding:20,border:'1px solid #e5eaf2',borderRadius:14}}>
          <div style={{display:'flex',justifyContent:'space-between',gap:8,alignItems:'center'}}>
            <strong>{name}</strong><span style={{fontSize:11,color:status==='Foundation'?'#047857':'#64748b',background:'#f1f5f9',padding:'5px 8px',borderRadius:20}}>{status}</span>
          </div>
          <p style={{color:'#64748b',fontSize:14,lineHeight:1.5}}>{desc}</p>
        </article>)}
      </div>
      <footer style={{marginTop:36,color:'#94a3b8',fontSize:12}}>Phase 1 only. Authentication and live finance workflows are not yet enabled.</footer>
    </main>
  );
}