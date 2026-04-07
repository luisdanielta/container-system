

psql -U postgres_shared -d postgres
CREATE DATABASE coder;
CREATE DATABASE sonar;
CREATE DATABASE penpot;
CREATE DATABASE teable;
CREATE DATABASE mattermost;
CREATE DATABASE n8n;

DROP DATABASE coder;

psql -U postgres_xaiena -d postgres
CREATE DATABASE cookery;