use FileSystem::Helpers;

package KV {
    grammar Grammar {
        token TOP { <.ws> <kv>* %% \v+ <.ws> || <parse-error> }
        token kv  { <key> [ ":" || <parse-error> ] <.ws> <val> }
        token key { <-[\s:]>+ }
        token val { <-[\v]>* }
        token parse-error { .* }
        class Actions {
            method TOP($/) {
                with $/<parse-error> { fail "could not parse: $_" };
                my $data = %();
                $data{$_<key>} = $_<val> for $/<kv>.map: *.made;
                make $data;
            }
            method kv($/) {
                with $/<parse-error> { fail "could not parse: $_" };
                make %(
                    key => $/<key>,
                    val => $/<val>,
                );
            }
        }
        method parse($target, Mu :$actions = Actions, |c) {
            callwith($target, :actions($actions), |c)
        }
    }
}

sub MAIN(IO() :$src is required, IO() :$dst is required) {
    FileSystem::Helpers::copy-dir $src, $dst, :mod(-> IO:D $f {
        my $raw = $f.slurp;
        my $doc = $raw ~~ / [ [ ^^ '---' $$ ] ~ [ ^^ '---' $$ ] $<frontmatter>=([ <-[-]> | '-' <!before '--' \v> ]*) ]? $<content>=.* /;
        my $content = $doc<content>.Str;
        my $metadata = %();
        with $doc<frontmatter> { $metadata = KV::Grammar.parse($_.Str).made };
        (not ($metadata<live>.defined and $metadata<live> eq 'true')) ?? Any !! do {
            $metadata<modified> = $f.modified.DateTime.Str;
            my $new-fm = $metadata.kv.map(-> $k, $v { "$k: $v" }).join("\n");
            my $new-raw = "---\n$new-fm\n---\n\n$content";
            $new-raw
        }
    });
}

