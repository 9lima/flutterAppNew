import models as _models
import sqlalchemy.orm as _orm
import sqlalchemy as _sql
import time, random
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF



def create_get_db():
    if not (_sql.inspect(_models.engine).has_table("x25519") and _sql.inspect(_models.engine).has_table("users")):
        _models.Base.metadata.drop_all(_models.engine)
        _models.Base.metadata.create_all(_models.engine)

    db = _models.SessionLocal()
    try:
        yield db
    finally:
        db.close()





async def get_user_by_owner_id(owner_id: str , db: _orm.Session):
    query = _sql.select(_models.User).where( _sql.func.substr(_models.User.owner_id, 1, _sql.func.instr(_models.User.owner_id, "@") - 1 ) == owner_id)
    result = db.execute(query)
    if result:
        return result.scalars().first()
    else:
        return False




def get_newest_KeyRows(db: _orm.Session):
    x25519_stmt = (_sql.select(_models.X25519_Key).order_by(_models.X25519_Key.x25519_created_at.desc()).limit(1))
    x25519_result = db.execute(x25519_stmt).scalar_one_or_none()
    return (x25519_result)




class key_generating:
    __slots__ = ('pv_bytes', 'pub_bytes')

    def __init__(self):

        private_key = x25519.X25519PrivateKey.generate()
        public_key = private_key.public_key()

        self.pv_bytes = private_key.private_bytes(
                encoding=serialization.Encoding.Raw,
                format=serialization.PrivateFormat.Raw,
                encryption_algorithm=serialization.NoEncryption())

        self.pub_bytes = public_key.public_bytes(
                encoding=serialization.Encoding.Raw,
                format=serialization.PublicFormat.Raw)

    def key_pair_bytes(self) -> tuple[bytes, bytes]:
        return self.pv_bytes, self.pub_bytes






def sharedSecret_AES(clientPublicKeybytes: list, server_private_bytes: bytes, hkdfNonce:list):

    server_private_key = x25519.X25519PrivateKey.from_private_bytes(server_private_bytes)
    client_pub_bytes = bytes(clientPublicKeybytes)

    client_public_key = x25519.X25519PublicKey.from_public_bytes(client_pub_bytes)
    shared_secret = server_private_key.exchange(client_public_key)

    nonce = bytes(hkdfNonce)

    aes_key_bytes = HKDF(
        algorithm=hashes.SHA256(),
        length=32,
        salt=nonce,
        info=None,
    ).derive(shared_secret)

    return aes_key_bytes





def decrypt_aes(key: bytes, nonce: list, ciphertext: list, mac: list) -> bytes:
    try:
        nonce = bytes(nonce)
        ciphertext = bytes(ciphertext)
        mac = bytes(mac)
        aesgcm = AESGCM(key)
        data = aesgcm.decrypt(nonce, ciphertext + mac, None)

        return data
    except Exception as e:
        print(f"Error by AES decrypt: {e}")






def generating_x_keys():
    while True:
        try:
            db: _orm.Session = _models.SessionLocal()
            a = key_generating()
            server_pv, server_pub = a.key_pair_bytes()
            new_keys = _models.X25519_Key(pv_key=server_pv, pub_key=server_pub)
            db.add(new_keys)
            db.commit()
            db.refresh(new_keys)

        except Exception as e:
            db.rollback()
            print("Key generation error:", e)
        finally:
            db.close()

        time.sleep(random.randint(30*60,40*60))






class MT19937: 
     
    __slots__ = ( "w", "n", "m", "r", "a", "u", "d", "s", "b", "t", "c", "l", "f", "MT", "index", "lower_mask", "upper_mask", )

    def __init__(self, seed):
        self.w, self.n, self.m, self.r = 32, 624, 397, 31
        self.a = 0x9908B0DF
        self.u, self.d = 11, 0xFFFFFFFF
        self.s, self.b = 7, 0x9D2C5680
        self.t, self.c = 15, 0xEFC60000
        self.l = 18
        self.f = 1812433253

        self.MT = [0] * self.n
        self.index = self.n
        self.lower_mask = (1 << self.r) - 1
        self.upper_mask = (~self.lower_mask) & 0xFFFFFFFF

        self.seed_mt(seed)

    def seed_mt(self, seed):
        self.index = self.n
        self.MT[0] = seed & 0xFFFFFFFF
        for i in range(1, self.n):
            self.MT[i] = (
                self.f * (self.MT[i - 1] ^ (self.MT[i - 1] >> 30)) + i
            ) & 0xFFFFFFFF

    def extract_number(self):
        if self.index >= self.n:
            self.twist()

        y = self.MT[self.index]
        y ^= (y >> self.u)
        y ^= (y << self.s) & self.b
        y ^= (y << self.t) & self.c
        y ^= (y >> self.l)

        self.index += 1
        return y & 0xFFFFFFFF

    def twist(self):
        for i in range(self.n):
            x = (self.MT[i] & self.upper_mask) + (
                self.MT[(i + 1) % self.n] & self.lower_mask
            )
            xA = x >> 1
            if x & 1:
                xA ^= self.a
            self.MT[i] = self.MT[(i + self.m) % self.n] ^ xA
        self.index = 0

    def randint(self, max_value):
        if max_value <= 0:
            raise ValueError("max_value must be > 0")
        return self.extract_number() % max_value
        
    def unique_random_numbers(self, max_value, count):

      numbers = list(range(max_value + 1))
      
      for i in reversed(range(1, len(numbers))):
          j = self.randint(i + 1)
          numbers[i], numbers[j] = numbers[j], numbers[i]
      
      return numbers[:count]
    





def Nonce_MAC_secretKey(seed:int , maxValue:int , count:int, nonceandmac:list, len_nonce:int, len_mac:int):
    try:
        rng = MT19937(seed=seed)
        randomList = rng.unique_random_numbers( maxValue, count)

        unshuffled = [nonceandmac[i] for i in randomList]

        nonce = list(unshuffled[:len_nonce])
        mac = list(unshuffled[len_nonce:len_nonce + len_mac])
        sec = list(unshuffled[len_nonce + len_mac::])

        return nonce, mac, sec
    except:
        raise ValueError("Nonce_MAC_secretKey not found")
        






def decrypt_aes( key, nonce, ciphertext, mac) -> bytes:

    nonce = bytes(nonce)
    mac = bytes(mac)
    aesgcm = AESGCM(bytes(key))

    ciphertext = bytes(ciphertext)
    data = aesgcm.decrypt(nonce, ciphertext + mac, None)

    return data