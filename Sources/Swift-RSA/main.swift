import BigInt
import Foundation

func generatePrime(_ width: Int) -> BigUInt {
    while true {
        var random = BigUInt.randomInteger(withExactWidth: width)
        random |= BigUInt(1)
        if random.isPrime() {
            return random
        }
    }
}

class RSA {
    
    typealias Key = (modulus: BigUInt, exponent: BigUInt)
    
    let publicKey: Key
    let privateKey: Key
    
    init(primeLength: Int) {
        // Two large prime numbers
        let p = generatePrime(primeLength)
        let q = generatePrime(primeLength)
        print("======== p [large prime number] ========")
        print(p, terminator: "\n\n")
        print("======== q [large prime number] ========")
        print(q, terminator: "\n\n")
        
        // Modulus [PUBLIC]
        let m = p * q
        print("======== m [modulus] ========")
        print(m, terminator: "\n\n")
        
        // Euler Totient
        let t = (p - 1) * (q - 1)
        print("======== t [Euler Totient] ========")
        print(t, terminator: "\n\n")
        
        // Public Key [PUBLIC]
        let e = BigUInt(65537)
        print("======== e [Public Key] ========")
        print(e, terminator: "\n\n")
        
        // Private Key [PRIVATE]
        let d = BigUInt(e).inverse(BigUInt(t))!
        print("======== d [Private Key] ========")
        print(d, terminator: "\n\n")
        
        self.publicKey = (m, e)
        self.privateKey = (m, d)
    }
}

extension BigUInt {
    func endecrypt(RSAKey key: RSA.Key) -> BigUInt {
        return self.power(key.exponent, modulus: key.modulus)
    }
}


func main() {
    let args = CommandLine.arguments
    
    var primeLength = 64
    if let plIndex = args.index(of: "-pl"), args.count >= plIndex + 1 {
        if let pl = Int(args[plIndex + 1]) {
            primeLength = pl
        }
    }
    
    let encodeEachChar = args.contains("-ec")
    
    var plainText = "Hello, world!"
    if let msgIndex = args.index(of: "-m"), args.count >= msgIndex + 1 {
        plainText = args[msgIndex + 1]
    }
    
    let rsa = RSA(primeLength: primeLength)
    print("============ Start ============")
    print("Plain Text: \(plainText)\nPrime Length: \(primeLength)", terminator: "\n\n")
    
    if encodeEachChar {
        var secrets = [BigUInt]()
        var cipherTexts = [BigUInt]()
        var decryptedDatas = [BigUInt]()
        var decryptedMessages = ""
        
        for c in plainText {
            let secret = BigUInt(String(c).data(using: .utf8)!)
            let cipherText = secret.endecrypt(RSAKey: rsa.publicKey)
            
            let decryptedData = cipherText.endecrypt(RSAKey: rsa.privateKey)
            secrets.append(secret)
            cipherTexts.append(cipherText)
            decryptedDatas.append(decryptedData)
            
            if let decryptedMessage = String(data: decryptedData.serialize(), encoding: .utf8) {
                decryptedMessages += decryptedMessage
            } else {
                print("Error: Couldn't recover the character. \(decryptedData)")
                exit(1)
            }
            
        }
        
        print("Plain Text -> Data")
        print(secrets, terminator: "\n\n")
        print("Data -> Cipher Text")
        print(cipherTexts, terminator: "\n\n")
        print("Cipher Text -> Data")
        print(decryptedDatas, terminator: "\n\n")
        print("Data -> Decrypted Plain Text")
        print(decryptedMessages, terminator: "\n\n")
        
        
    } else {
        let secret = BigUInt(plainText.data(using: .utf8)!)
        print("Plain Text -> Data")
        print(secret, terminator: "\n\n")
        
        let cipherText = secret.endecrypt(RSAKey: rsa.publicKey)
        print("Data -> Cipher Text")
        print(cipherText, terminator: "\n\n")
        
        
        let decryptedData = cipherText.endecrypt(RSAKey: rsa.privateKey)
        print("Cipher Text -> Data")
        print(decryptedData, terminator: "\n\n")
        
        if let decryptedMessage = String(data: decryptedData.serialize(), encoding: .utf8) {
            print("Data -> Decrypted Plain Text")
            print(decryptedMessage, terminator: "\n\n")
        } else {
            print("Error: Couldn't recover the plain text from decrypted data. Try to tune the length of prime using -pl; or enter a short message.")
        }
    }

}


main()

