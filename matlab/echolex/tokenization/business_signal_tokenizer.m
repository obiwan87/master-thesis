%terms = string(m.Terms);
filelist = dir(business_signals_data);
filelist = filelist(~[filelist.isdir]);
original_files = cellfun(@(x) endsWith(x,'.txt'), {filelist.name}); % not preprocessed: string \t label
filelist = filelist(original_files);

Ds = cell(sum(original_files),1);

% Load stopwords from NLTK-database
replace_stopwords = false;
stopwords = cell(py.echolex.bridge2matlab.nltk_lazy_load.stopwords('german'))';
stopwords = cellfun(@char, stopwords, 'UniformOutput', false);
stopwords{end+1} = 'dass';
stopwords{end+1} = 'ab';
stopwords{end+1} = 'wurde';
stopwords{end+1} = 'wurden';
stopwords{end+1} = 'worden';
stopwords{end+1} = 'of';
stopwords{end+1} = 'the';
stopwords{end+1} = 'www';
stopwords{end+1} = 'http';
stopwords{end+1} = 'beim';

exclude_tokens = ['#', '@', '~', '.', '..', '...', ',', ';', ':', '(', ')', '"', '''', '[', ']', '{', '}', '?', '!', '-', '–', '+', '*', '--', '''''', '``'];
%number_regex = '^-?\d+((,|\.)\d+)*((,|\.)\d+(e\d+)?)?$';

tokenize_numbers = false;
number_regex = '^([0-9\-\.,]+|eins|zwei|drei|vier|fünf|sechs|sieben|acht|neun|zehn|elf|zwölf)$';
number_token = '<number>';

tokenize_jaehriges = false;
jaehriges_regex = '^([0-9]+|eins|zwei|drei|vier|fünf|sechs|sieben|acht|neun|zehn|elf|zwölf)\-?(jährig|jaehrig)(e|es|er|en|em)?$';
jaehriges_token = '<#-jähriges>';

remove_special_chars = false;
special_chars_regex = ['^[' regexptranslate('escape', special_chars) ']*$'];
neg_word_chars_regex = '[^A-Za-z0-9öäüßÖÄÜÂÃÅÑÚÞáâãçèéêíîïðñóôûąćęłńřśŠ€²šż́̈β\- ]';

replace_underscore = true;

replace_umlauts = true;
umlaut_replacement = { { 'Ä', 'Ae' }, {'Ö', 'Oe' }, {'Ü', 'Ue'} , {'ä', 'ae' }, {'ö', 'oe' }, {'ü', 'ue'}, {'ß', 'ss'} };

if replace_umlauts
    for i=1:numel(umlaut_replacement)
        stopwords = strrep(stopwords, umlaut_replacement{i}{1}, umlaut_replacement{i}{2});
    end
end

tokenizer = py.nltk.tokenize.TweetTokenizer();

for i=1:numel(Ds)
    tokenized_sentences = {};
    filepath = fullfile(filelist(i).folder, filelist(i).name);
    
    fid = fopen(filepath);
    tline = fgetl(fid);
    labels = [];
    j = 1;
    while ischar(tline)
        tline = strtrim(tline);
        row = strsplit(tline, '\t');
        sentence = row{1};
        label = str2double(row{2});
        labels = [labels; label];
        
        % Remove special characters except "-"
        matches = regexp(sentence, '');        
        tokens = cell(tokenizer.tokenize(sentence));        
        tokens = string(cellfun(@char, tokens, 'UniformOutput', false));
        
        if remove_special_chars
            % Remove non-word-characters with
            tokens = regexprep(tokens, neg_word_chars_regex, '');
        end
        
        if tokenize_numbers
            % Replace numbers with <numbers> token
            tokens = regexprep(tokens, number_regex, number_token, 'ignorecase');
        end
        
        if tokenize_jaehriges
            % Replace -jaeheriges expression
            tokens = regexprep(tokens, jaehriges_regex, jaehriges_token, 'ignorecase');
        end
        
        if replace_underscore
            tokens = strrep(tokens, '_', '--');
        end
        
        % Remove words consisting of only "-"
        % tokens = regexprep(tokens,'^-+$','');
        tokens(tokens == '') = [];
        
        % Replace Umlauts
        if replace_umlauts
            for k=1:numel(umlaut_replacement)
                tokens = strrep(tokens, umlaut_replacement{k}{1}, umlaut_replacement{k}{2});
            end
        end
        
        if replace_stopwords
            tokens_lower = lower(tokens);
            stopwords_idx = find(sum(tokens_lower == stopwords));
            
            tokens(stopwords_idx) = [];
        end
        tokenized_sentences{j} = tokens.cellstr;
        tline = fgetl(fid);
        j = j + 1;
    end
    
    Ds{i} = io.DocumentSet(tokenized_sentences', labels);   
    Ds{i}.prepare();
end

