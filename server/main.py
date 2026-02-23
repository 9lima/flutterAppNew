import schemas as _schemas
import services as _services
from models import User, Base, engine
import fastapi as _fastapi
import sqlalchemy.orm as _orm
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.cors import CORSMiddleware
from secrets import choice   
import random,string, threading, asyncio
import uuid, pathlib


Base.metadata.drop_all(engine)
Base.metadata.create_all(engine)

threads = [threading.Thread(target=_services.generating_x_keys, daemon=True)]
for t in threads:
    t.start()


app = _fastapi.FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@app.post("/key")
async def create_user(user:_schemas.PublicKeyRequest_Base, db: _orm.Session = _fastapi.Depends(_services.create_get_db)):


    delay = random.uniform(0.0039, 0.0089)
    await asyncio.sleep(delay)


    user_exist = await _services.get_user_by_owner_id(user.ownerId, db)
    if user_exist:
       
        key_response = {"ownerId": user_exist.owner_id, "pubKey": user_exist.x25519_key_id}
        Public_Key_Response = _schemas.PublicKeyResponse.model_validate(key_response)
        return Public_Key_Response.model_dump(mode='json')

    
    x25519PubKey = user.x25519PubKey[:16]+ user.hkdfNonce
    hkdfNonce = user.x25519PubKey[16:]


    
    row_object_x25519 = _services.get_newest_KeyRows(db)
    server_pv, server_pub = (row_object_x25519.pv_key, row_object_x25519.pub_key)

    aes = _services.sharedSecret_AES(x25519PubKey, server_pv, hkdfNonce)
    
    new_owner_id = str(user.ownerId+"@"+''.join(choice(string.printable.replace('@', '')) for _ in range(7)))

    key_response = {"ownerId": user.ownerId, "pubKey": list(server_pub)}
    Public_Key_Response = _schemas.PublicKeyResponse.model_validate(key_response)

    db_user = User(owner_id=new_owner_id,  x25519_key_id=row_object_x25519.id,
                    clientPublicKeyBytes = bytes(x25519PubKey), sharedSecret_AES=aes, hkdfNonce=bytes(hkdfNonce))
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    print(Public_Key_Response.model_dump(mode='json'))
    print('*'*10, list(aes))
    return Public_Key_Response.model_dump(mode='json')

    


@app.post("/dataa")
async def upload_cipher(req:_schemas.EncryptionResponseModel, db: _orm.Session = _fastapi.Depends(_services.create_get_db)):
    try:
        NMMvCS = req.NMMvCS
        n,m,s = _services.Nonce_MAC_secretKey(seed = NMMvCS[-1], maxValue=NMMvCS[2], count=NMMvCS[-2], nonceandmac=req.finalList, len_nonce=NMMvCS[0], len_mac=NMMvCS[1])
        
        print(n)
        path = pathlib.Path('.') / 'images' / (str(uuid.uuid4()) + '.jpg')

        with open(path, "wb") as f:
                f.write(_services.decrypt_aes(s,n,req.ciphertext,m))
            
        return {'response':'response'}
    
    except Exception as e:
         print(e)
         return {'response':'Error'}



# return 200 OK for HEAD
@app.head("/")
async def root_head():
    return {}  