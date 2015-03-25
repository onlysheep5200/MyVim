fun! SetUp()
    exe ':set tags='
endf

fun! TestCase_returns_slash_when_no_namespace_found()
    call SetUp()
    let [namespace, imports] = phpcomplete#GetCurrentNameSpace([])
    call VUAssertEquals('\', namespace)
endf

fun! TestCase_returns_namespace_from_file_lines()
    call SetUp()
    let file_lines = readfile(expand('%:p:h').'/'.'fixtures/GetCurrentNameSpace/single_namespace.php')
    let [namespace, imports] = phpcomplete#GetCurrentNameSpace(file_lines)
    call VUAssertEquals('Mahou', namespace)
endf

fun! TestCase_returns_closest_namespace_from_the_current_line()
    call SetUp()
    let file_lines = readfile(expand('%:p:h').'/'.'fixtures/GetCurrentNameSpace/multiple_namespace.php')
    let [namespace, imports] = phpcomplete#GetCurrentNameSpace(file_lines)
    call VUAssertEquals('FindMe', namespace)
endf

fun! TestCase_returns_imported_namespaces_and_classes_with_their_info_from_tags()
    call SetUp()

    exe 'set tags='.expand('%:p:h')."/".'fixtures/common/namespaced_foo_tags'
    let file_lines = readfile(expand('%:p:h').'/'.'fixtures/GetCurrentNameSpace/imports.php')

    call phpcomplete#LoadData()

    let [namespace, imports] = phpcomplete#GetCurrentNameSpace(file_lines)
    call VUAssertEquals({
                \ 'Foo': {'cmd': '/^class Foo {$/', 'static': 0, 'name': 'Foo', 'namespace': 'NS1', 'kind': 'c', 'builtin': 0, 'filename': 'fixtures/common/namespaced_foo.php'},
                \ 'ArrayAccess': {'name': 'ArrayAccess', 'kind': ''},
                \ 'AO': {'name': 'ArrayObject', 'kind': ''},
                \ 'DateTimeZone': {'name': 'DateTimeZone', 'kind': ''},
                \ 'LE': {'name': 'LogicException', 'kind': ''},
                \ 'DateTime': {'name': 'DateTime', 'kind': ''},
                \ 'SUBNS': {'cmd': '/^namespace NS1\\SUBNS;$/', 'static': 0, 'name': 'NS1\SUBNS', 'kind': 'n', 'builtin': 0, 'filename': 'fixtures/common/namespaced_foo.php'},
                \ 'EE': {'name': 'ErrorException', 'kind': ''},
                \ 'E': {'name': 'Exception', 'kind': ''}},
                \ imports)

    " with old style tags, no namespace matches will be returned and the first
    " and the class tags are matched regardeless of their namespace while
    " namespace import just not recognized with the kind 'n' and filename
    exe 'set tags='.expand('%:p:h')."/".'fixtures/common/old_style_namespaced_foo_tags'
    let [namespace, imports] = phpcomplete#GetCurrentNameSpace(file_lines)
    call VUAssertEquals({
                \ 'Foo': {'cmd': '/^class Foo {$/', 'static': 0, 'name': 'Foo', 'kind': 'c', 'builtin': 0, 'filename': 'fixtures/common/fixtures/common/namespaced_foo.php'},
                \ 'ArrayAccess': {'name': 'ArrayAccess', 'kind': ''},
                \ 'AO': {'name': 'ArrayObject', 'kind': ''},
                \ 'DateTimeZone': {'name': 'DateTimeZone', 'kind': ''},
                \ 'LE': {'name': 'LogicException', 'kind': ''},
                \ 'DateTime': {'name': 'DateTime', 'kind': ''},
                \ 'SUBNS': {'name': 'SUBNS', 'namespace': 'NS1', 'kind': '', 'builtin': 0},
                \ 'EE': {'name': 'ErrorException', 'kind': ''},
                \ 'E': {'name': 'Exception', 'kind': ''}},
                \ imports)
endf
