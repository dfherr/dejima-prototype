createuser -U postgres --superuser dejima
psql -U postgres -c "alter user dejima with password 'barfoo'"