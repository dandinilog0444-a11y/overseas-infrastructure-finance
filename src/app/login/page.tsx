import { signIn } from '@/lib/actions';

export default function LoginPage() {
  return <main style={{maxWidth:420,margin:'8vh auto',padding:24,background:'white',border:'1px solid #e5eaf2',borderRadius:16}}>
    <h1 style={{fontSize:26}}>Sign in</h1>
    <p style={{color:'#64748b'}}>Overseas Infrastructure Finance</p>
    <form action={signIn} style={{display:'grid',gap:12,marginTop:24}}>
      <label>Email<input name="email" type="email" required autoComplete="username" style={field}/></label>
      <label>Password<input name="password" type="password" required autoComplete="current-password" style={field}/></label>
      <button style={{background:'#14213d',color:'white',padding:12,border:0,borderRadius:9,fontWeight:700}}>Sign in</button>
    </form>
  </main>;
}
const field = {display:'block',width:'100%',padding:12,marginTop:6,border:'1px solid #cbd5e1',borderRadius:8} as const;