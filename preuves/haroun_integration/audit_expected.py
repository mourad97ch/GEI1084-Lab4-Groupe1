from pathlib import Path
import json
repo=Path(__file__).resolve().parents[2];sim=repo/'phase4/sim'
M=(1<<32)-1
def cond(c,f):
 n,z,k,v=[bool(f&(1<<i)) for i in (3,2,1,0)]
 return [z,not z,k,not k,n,not n,v,not v,k and not z,not(k and not z),n==v,n!=v,not z and n==v,not(not z and n==v),True,False][c]
results=[]
for path in sorted(sim.glob('*.trace')):
 program=[int(x,16) for x in path.with_suffix('.hex').read_text().split()]
 regs=[0]*15;memory={};pc=0;flags=0;errors=[]
 for cycle,line in enumerate(path.read_text().splitlines(),1):
  t=line.split();i=program[pc//4];op=(i>>26)&3;rn=(i>>16)&15;rd=(i>>12)&15
  def rr(r):return (pc+8)&M if r==15 else regs[r]
  ce=int(cond(i>>28,flags));a=rr(15 if op==2 else rn)
  ra2=rd if op==1 and not(i>>20)&1 else i&15
  wd=rr(ra2);b=wd;rw=mw=fw=0;opcode=(i>>21)&15
  if op==0:
   if (i>>25)&1:b=i&255
   elif not(i>>4)&1:
    sh=(i>>5)&3;n=(i>>7)&31
    if sh==0:b=(b<<n)&M
    elif sh==1:b=b>>(n if n else 32)
   if opcode in (2,10):res=(a-b)&M;c=int(a>=b);v=int(bool((a^b)&(a^res)&0x80000000))
   elif opcode==4:res=(a+b)&M;c=int(a+b>M);v=int(bool((~(a^b))&(a^res)&0x80000000))
   elif opcode==0:res=a&b;c=v=0
   elif opcode==12:res=a|b;c=v=0
   else:raise ValueError(hex(i))
   rw=ce if opcode!=10 else 0
   fw=(3 if opcode in (2,4,10) else 2) if (opcode==10 or (i>>20)&1) and ce else 0
  elif op==1:
   res=(a+(i&4095))&M;c=v=0
   rw=ce if (i>>20)&1 else 0;mw=ce if not(i>>20)&1 else 0
  elif op==2:
   off=i&0xffffff
   if off&0x800000:off-=1<<24
   b=(off*4)&M;res=(a+b)&M;c=int(a+b>M);v=int(bool((~(a^b))&(a^res)&0x80000000))
   rw=ce if(i>>24)&1 else 0
  else:res=(a+b)&M;c=int(a+b>M);v=0
  ps=int(bool(ce and (op==2 or (rd==15 and rw))))
  pre=[f'{pc:08X}',f'{i:08X}',f'{res:08X}',f'{wd:08X}',f'{flags:X}',str(rw),str(mw),str(ps),str(fw),str(ce)]
  wb=memory.get(res&63,0) if op==1 and(i>>20)&1 else res
  if mw:memory[res&63]=wd
  if rw:
   dest=14 if op==2 else rd
   if dest<15:regs[dest]=(pc+4)&M if op==2 else wb
  newflags=((res>>31)<<3)|(int(res==0)<<2)|(c<<1)|v
  if fw&2:flags=(flags&3)|(newflags&12)
  if fw&1:flags=(flags&12)|(newflags&3)
  pc=res if ps else (pc+4)&M
  expected=pre+[f'{pc:08X}',f'{flags:X}']+[f'{r:08X}' for r in regs]
  if [x.upper() for x in t]!=expected:
   errors.append({'cycle':cycle,'differences':[{'column':k,'supplied':x,'recomputed':y} for k,(x,y) in enumerate(zip(t,expected)) if x.upper()!=y]})
 results.append({'trace':path.name,'cycles':cycle,'errors':errors})
out=repo/'preuves/haroun_integration/audit_attendus_independant.json'
out.write_text(json.dumps(results,indent=2),encoding='utf-8')
print('Audited',len(results),'traces;',sum(len(r['errors']) for r in results),'mismatched rows')
for r in results:
 if r['errors']:print(r['trace'],r['errors'][:2])
