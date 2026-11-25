import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
    status, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
  try {
    const url = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const authHeader = req.headers.get('Authorization') ?? '';
    if (!authHeader.startsWith('Bearer ')) return json({ error: 'Unauthorized' }, 401);

    const callerClient = createClient(url, anonKey, { global: { headers: { Authorization: authHeader } } });
    const { data: callerData, error: callerError } = await callerClient.auth.getUser();
    if (callerError || !callerData.user) return json({ error: 'Invalid session' }, 401);

    const admin = createClient(url, serviceKey);
    const { data: callerProfile, error: profileError } = await admin
      .from('profiles').select('role,is_active').eq('id', callerData.user.id).single();
    if (profileError || callerProfile?.role !== 'admin' || callerProfile?.is_active !== true) {
      return json({ error: 'Hanya Admin aktif yang dapat mengelola akun.' }, 403);
    }

    const body = await req.json();
    if (body.action === 'create_coach') {
      const email = String(body.email ?? '').trim().toLowerCase();
      const password = String(body.password ?? '');
      if (!email || password.length < 8) return json({ error: 'Email dan password minimal 8 karakter wajib diisi.' }, 400);
      const { data: created, error: createError } = await admin.auth.admin.createUser({
        email, password, email_confirm: true,
        user_metadata: {
          full_name: String(body.full_name ?? '').trim(),
          identifier: String(body.identifier ?? '').trim(),
          class_name: String(body.class_name ?? '').trim(),
          major: String(body.major ?? '').trim(),
          role: 'siswa',
        },
      });
      if (createError || !created.user) return json({ error: createError?.message ?? 'Gagal membuat akun.' }, 400);
      const { error: updateError } = await admin.from('profiles').upsert({
        id: created.user.id,
        full_name: String(body.full_name ?? '').trim(),
        email,
        identifier: String(body.identifier ?? '').trim() || null,
        role: 'pembina',
        class_name: String(body.class_name ?? '').trim(),
        major: String(body.major ?? '').trim(),
        is_active: true,
      });
      if (updateError) {
        await admin.auth.admin.deleteUser(created.user.id);
        return json({ error: updateError.message }, 400);
      }
      const cabang = String(body.class_name ?? '').trim();
      if (cabang) {
        await admin.from('extracurriculars').update({ coach_id: created.user.id, coach_name: String(body.full_name ?? '').trim() }).ilike('name', cabang);
      }
      return json({ user_id: created.user.id, email, full_name: body.full_name, role: 'pembina' });
    }

    const userId = String(body.user_id ?? '');
    if (!userId) return json({ error: 'user_id wajib diisi.' }, 400);
    if (body.action === 'update_coach_profile') {
      const email = String(body.email ?? '').trim().toLowerCase();
      const fullName = String(body.full_name ?? '').trim();
      const identifier = String(body.identifier ?? '').trim();
      const className = String(body.class_name ?? '').trim();
      const major = String(body.major ?? '').trim();
      const { error: updateError } = await admin.from('profiles').update({
        full_name: fullName, identifier: identifier || null, email,
        class_name: className, major,
      }).eq('id', userId).eq('role', 'pembina');
      if (updateError) return json({ error: updateError.message }, 400);
      await admin.from('extracurriculars').update({ coach_id: null }).eq('coach_id', userId);
      if (className) {
        await admin.from('extracurriculars').update({ coach_id: userId, coach_name: fullName }).ilike('name', className);
      }
      return json({ user_id: userId, email, full_name: fullName });
    }
    if (body.action === 'set_active') {
      const { error } = await admin.from('profiles').update({ is_active: body.is_active === true }).eq('id', userId);
      if (error) return json({ error: error.message }, 400);
      return json({ user_id: userId, is_active: body.is_active === true });
    }
    if (body.action === 'reset_password') {
      const password = String(body.password ?? '');
      if (password.length < 8) return json({ error: 'Password minimal 8 karakter.' }, 400);
      const { error } = await admin.auth.admin.updateUserById(userId, { password });
      if (error) return json({ error: error.message }, 400);
      return json({ user_id: userId, password_updated: true });
    }
    return json({ error: 'Action tidak dikenal.' }, 400);
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : String(error) }, 500);
  }
});
