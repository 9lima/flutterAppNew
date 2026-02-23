import pydantic as _pydantic
from typing import List


class PublicKeyRequest_Base(_pydantic.BaseModel):
    ownerId: str
    x25519PubKey: List[int]
    hkdfNonce: List[int]
    
    model_config = _pydantic.ConfigDict(from_attributes=True)




class PublicKeyResponse(_pydantic.BaseModel):
    ownerId: str
    pubKey: List[int]




class EncryptionResponseModel(_pydantic.BaseModel):
    ownerId: str
    ciphertext: List[int]
    
# NMMvCS is [lenNonce, lenMAC, maxValue, count, seed]
    NMMvCS: List[int]

    finalList: List[int]
    error: str | None

