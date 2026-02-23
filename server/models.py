from datetime import datetime
import sqlalchemy as _sql
import sqlalchemy.orm as _orm
from sqlalchemy.orm import DeclarativeBase

engine = _sql.create_engine("sqlite:///database.db", connect_args={"check_same_thread": False}, pool_pre_ping=True,pool_size=10,max_overflow=20,)
SessionLocal = _orm.sessionmaker(autocommit=False, bind=engine)


class Base(DeclarativeBase):
    pass


class X25519_Key(Base):
    __tablename__ = "x25519"

    id = _sql.Column(_sql.Integer, primary_key=True, index=True)

    pv_key = _sql.Column(_sql.LargeBinary, unique=True)
    pub_key = _sql.Column(_sql.LargeBinary, unique=True)

    # YYYYMMDDHHMMSS
    x25519_created_at = _sql.Column(_sql.Integer, default=int(datetime.now().strftime("%Y%m%d%H%M%S")))


    users = _orm.relationship("User", back_populates="key_x", cascade="all, delete-orphan")



class User(Base):
    __tablename__ = "users"

    id = _sql.Column(_sql.Integer, primary_key=True, index = True)
    owner_id = _sql.Column( _sql.String, index=True )

    hkdfNonce = _sql.Column(_sql.LargeBinary, unique=True)
    
    clientPublicKeyBytes = _sql.Column(_sql.LargeBinary, nullable=True)
    sharedSecret_AES = _sql.Column(_sql.LargeBinary, nullable=True)
    x25519_key_id = _sql.Column(_sql.Integer,_sql.ForeignKey("x25519.id"))

    key_x = _orm.relationship("X25519_Key", back_populates="users")

