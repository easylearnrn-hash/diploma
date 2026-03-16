const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const configContent = fs.readFileSync('js/supabase-config.js', 'utf8');
const urlMatch = configContent.match(/url:\s*'([^']+)'/);
const keyMatch = configContent.match(/anonKey:\s*'([^']+)'/);
const supabase = createClient(urlMatch[1], keyMatch[1]);

async function check() {
  const { data, error } = await supabase.from('students').select('full_name, group, group_name').eq('group', 'BSN 101').limit(3);
  console.log(data);
}
check();
