use strict;

use Test::More;

plan tests => 14;

use SQL::Abstract;
use SQL::Abstract::Plugin::InsertMulti;

can_ok('SQL::Abstract', qw/insert_multi update_multi/);
my $sql = SQL::Abstract->new;
isa_ok($sql, 'SQL::Abstract');

diag("hashref list");

{
    my $now = time;
    
    my ($stmt, @bind) = $sql->insert_multi(
        'app_data',
        [
            +{ app_id => 1, guid => 1, name => 'score', value => 100, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 1, name => 'last_login', value => \'UNIX_TIMESTAMP()', created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'score', value => 200, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'last_login', value => $now, created_on => \'NOW()', updated_on => \'NOW()', }
        ],
    );

    note($stmt);
    
    is(
        $stmt,
        q|INSERT INTO app_data ( app_id, created_on, guid, name, updated_on, value ) |
            . q|VALUES ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), UNIX_TIMESTAMP() ), ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), ? )|,
        'insert_multi statement test'
    );
    is_deeply(\@bind, [
        1, 1, 'score', 100,
        1, 1, 'last_login', 
        1, 2, 'score', 200,
        1, 2, 'last_login', $now,
    ], 'insert_multi bind test');
}

{
    my $now = time;
    
    my ($stmt, @bind) = $sql->insert_multi(
        'app_data',
        [
            +{ app_id => 1, guid => 1, name => 'score', value => 100, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 1, name => 'last_login', value => \'UNIX_TIMESTAMP()', created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'score', value => 200, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'last_login', value => $now, created_on => \'NOW()', updated_on => \'NOW()', }
        ],
        +{ ignore => 1, }
    );

    note($stmt);
    
    is(
        $stmt,
        q|INSERT IGNORE app_data ( app_id, created_on, guid, name, updated_on, value ) |
            . q|VALUES ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), UNIX_TIMESTAMP() ), ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), ? )|,
        'insert_multi statement test with ignore option'
    );
    is_deeply(\@bind, [
        1, 1, 'score', 100,
        1, 1, 'last_login', 
        1, 2, 'score', 200,
        1, 2, 'last_login', $now,
    ], 'insert_multi bind test with ignore option');
}


{
    my $now = time;
    
    my ($stmt, @bind) = $sql->update_multi(
        'app_data',
        [
            +{ app_id => 1, guid => 1, name => 'score', value => 100, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 1, name => 'last_login', value => \'UNIX_TIMESTAMP()', created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'score', value => 200, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'last_login', value => $now, created_on => \'NOW()', updated_on => \'NOW()', }
        ],
    );

    note($stmt);
    
    is(
        $stmt,
        q|INSERT INTO app_data ( app_id, created_on, guid, name, updated_on, value ) |
            . q|VALUES ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), UNIX_TIMESTAMP() ), ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), ? ) |
            . q|ON DUPLICATE KEY UPDATE app_id = VALUES( app_id ), created_on = VALUES( created_on ), guid = VALUES( guid ), name = VALUES( name ), updated_on = VALUES( updated_on ), value = VALUES( value )|,
        'update_multi statement test'
    );
    is_deeply(\@bind, [
        1, 1, 'score', 100,
        1, 1, 'last_login', 
        1, 2, 'score', 200,
        1, 2, 'last_login', $now,
    ], 'update_multi bind test');
}

{
    my $now = time;
    
    my ($stmt, @bind) = $sql->insert_multi(
        'app_data',
        [
            +{ app_id => 1, guid => 1, name => 'score', value => 100, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 1, name => 'last_login', value => \'UNIX_TIMESTAMP()', created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'score', value => 200, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'last_login', value => $now, created_on => \'NOW()', updated_on => \'NOW()', }
        ],
        +{ update => +{ updated_on => $now }, }
    );

    note($stmt);
    
    is(
        $stmt,
        q|INSERT INTO app_data ( app_id, created_on, guid, name, updated_on, value ) |
            . q|VALUES ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), UNIX_TIMESTAMP() ), ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), ? ) |
            . q|ON DUPLICATE KEY UPDATE updated_on = ?|,
        'insert_multi statement test with update option'
    );
    is_deeply(\@bind, [
        1, 1, 'score', 100,
        1, 1, 'last_login', 
        1, 2, 'score', 200,
        1, 2, 'last_login', $now,
        $now, 
    ], 'insert_multi bind test with update option');
}

{
    my $now = time;
    
    my ($stmt, @bind) = $sql->update_multi(
        'app_data',
        [
            +{ app_id => 1, guid => 1, name => 'score', value => 100, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 1, name => 'last_login', value => \'UNIX_TIMESTAMP()', created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'score', value => 200, created_on => \'NOW()', updated_on => \'NOW()', },
            +{ app_id => 1, guid => 2, name => 'last_login', value => $now, created_on => \'NOW()', updated_on => \'NOW()', }
        ],
        +{ update_ignore_fields => [qw/app_id guid name created_on/], }
    );

    note($stmt);
    
    is(
        $stmt,
        q|INSERT INTO app_data ( app_id, created_on, guid, name, updated_on, value ) |
            . q|VALUES ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), UNIX_TIMESTAMP() ), ( ?, NOW(), ?, ?, NOW(), ? ), ( ?, NOW(), ?, ?, NOW(), ? ) |
            . q|ON DUPLICATE KEY UPDATE updated_on = VALUES( updated_on ), value = VALUES( value )|,
        'update_multi statement test with update_ignore_fields option'
    );
    is_deeply(\@bind, [
        1, 1, 'score', 100,
        1, 1, 'last_login', 
        1, 2, 'score', 200,
        1, 2, 'last_login', $now,
    ], 'update_multi bind test with update_ignore_fields option');
}

diag("arrayref list");

{
    my $now = time;
    
    my ($stmt, @bind) = $sql->insert_multi(
        'app_data',
        [qw/app_id guid name value created_on updated_on/],
        [
            [ 1, 1, 'score', 100, \'NOW()', \'NOW()', ],
            [ 1, 1, 'last_login', \'UNIX_TIMESTAMP()', \'NOW()', \'NOW()', ],
            [ 1, 2, 'score', 200, \'NOW()', \'NOW()', ],
            [ 1, 2, 'last_login', $now, \'NOW()', \'NOW()',]
        ],
    );

    note($stmt);
    
    is(
        $stmt,
        q|INSERT INTO app_data ( app_id, guid, name, value, created_on, updated_on ) |
            . q|VALUES ( ?, ?, ?, ?, NOW(), NOW() ), ( ?, ?, ?, UNIX_TIMESTAMP(), NOW(), NOW() ), ( ?, ?, ?, ?, NOW(), NOW() ), ( ?, ?, ?, ?, NOW(), NOW() )|,
        'insert_multi statement test'
    );
    is_deeply(\@bind, [
        1, 1, 'score', 100,
        1, 1, 'last_login', 
        1, 2, 'score', 200,
        1, 2, 'last_login', $now,
    ], 'insert_multi bind test');
}
