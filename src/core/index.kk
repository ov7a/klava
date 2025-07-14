import utils/map

pub alias token = string

pub alias score = int
pub alias doc_id = int

pub value struct term_index
  total: score
  docs: map<doc_id, score>

pub struct doc
  url: string
  title: string
  tags: list<string>

// should I use different struct for search? Yes. Is it worth it? Nah
pub value struct index
  docs: vector<doc>
  terms: map<token, term_index>
  normalizers: vector<float64>