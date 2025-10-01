# This script enables full background coloring of buffer regions.
# Author: Francois Tonneau

define-command -docstring \
'shadow-set <filetype> <shadow_id> <opening_regex> <closing_regex> <first|nofirst> <last|nolast> <face> ...' \
-params 7.. shadow-set %{
    evaluate-commands %sh{
        fit=$1
        shift
        while test "$#" != 0; do
            id=$1
            open=$2
            close=$3
            modefirst=$4
            if test "$modefirst" = nofirst; then
                check_first='exec <a-:><a-semicolon> J'
            else
                check_first=
            fi
            modelast=$5
            if test "$modelast" = nolast; then
                check_last='exec <a-:> K'
            else
                check_last='exec <a-:>'
            fi
            face=$6
            printf %s "
                define-command -hidden shadow-update-areas-$fit-$id %{
                    addhl -override window/shadow-area-$fit-$id group
                    try %{
                        eval -draft %{
                            exec <percent> s '$open.*?' '$close' <ret>
                            $check_first
                            $check_last
                            exec <a-s>
                            eval -itersel %{
                                addhl window/shadow-area-$fit-$id/ line %val(cursor_line) '$face'
                            }
                        }
                    }
                }
                hook global WinSetOption filetype=$fit %{
                    hook -group shadow-area window NormalIdle .* shadow-update-areas-$fit-$id 
                    hook -group shadow-area window InsertIdle .* shadow-update-areas-$fit-$id 
                    hook -once -always window WinSetOption filetype=.* %{
                        remove-hooks window shadow-area
                    }
                }
            " 
            shift
            shift
            shift
            shift
            shift
            shift
        done
    }
}

define-command -docstring \
'shadow-decorate <filetype> <decor_id> <line_regex> <face> ...' \
-params 4.. shadow-decorate %{
    evaluate-commands %sh{
        fit=$1
        shift
        while test "$#" != 0; do
            id=$1
            regex=$2
            face=$3
            printf %s "
                define-command -hidden shadow-update-fences-$fit-$id %{
                    addhl -override window/shadow-fence-$fit-$id group
                    try %{
                        eval -draft %{
                            exec <percent> s '$regex' <ret>
                            eval -itersel %{
                                addhl window/shadow-fence-$fit-$id/ line %val(cursor_line) '$face'
                            }
                        }
                    }
                }
                hook global WinSetOption filetype=$fit %{
                    hook -group shadow-fence window NormalIdle .* shadow-update-fences-$fit-$id 
                    hook -group shadow-fence window InsertIdle .* shadow-update-fences-$fit-$id 
                    hook -once -always window WinSetOption filetype=.* %{
                        remove-hooks window shadow-fence
                    }
                }
            " 
            shift
            shift
            shift
        done
    }
}

