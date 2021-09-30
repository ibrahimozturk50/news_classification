from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtGui import *
import pickle
from bs4 import BeautifulSoup

import sys
import requests


class Pencere(QWidget):
    def __init__(self):
        super().__init__()
        self.setUI()

    def setUI(self):
        baslik = QLabel("")
        aciklamaLabel = QLabel("URL giriniz:")
        aciklamaLabel.setStyleSheet("color: rgb(255,0,);font-weight: bold; font-size: 16pt")

        kategorilabel = QLabel("Kategori Sayıları:")
        yuzdelabel = QLabel("Kategori Yüzdeleri:")

        logo = QLabel()
        self.giris = QLineEdit()
        gonder = QPushButton()

        self.alinanhaber = QLineEdit()
        self.yuzde = QTextEdit()

        # BASLIK
        baslik.setText("""
            <h1><font color =/"green/"> Kategori Ölçer </font></h1>
        """)
        baslik.setFont(QFont("Helvetic", 15, QFont.Bold))
        baslik.setAlignment(Qt.AlignCenter)


        # LOGO
        logo.setPixmap(QPixmap("C:/tubitak_logo.jpg"))
        logo.setMinimumHeight(50)

        # BUTTON
        gonder.setIcon(QIcon("C:/tubitak_logo.jpg"))

        gonder.setMinimumHeight(50)
        gonder.setStyleSheet("font-weight: bold; font-size: 16pt")

        h_box = QHBoxLayout()


        v_box = QVBoxLayout()

        v_box.addWidget((baslik))
        v_box.addWidget(aciklamaLabel)
        v_box.addWidget(self.alinanhaber)
        v_box.addWidget(gonder)
        v_box.addWidget(kategorilabel)
        v_box.addWidget(self.giris)
        v_box.addWidget(yuzdelabel)
        v_box.addWidget(self.yuzde)
        v_box.addLayout(h_box)

        self.resize(900, 500)
        self.move(500, 200)
        gonder.clicked.connect(self.uygula)
        self.setLayout(v_box)
        self.show()
        self.setWindowTitle('Haber Alıcı v1.0')



    def tahmin(self,haber):
        import pickle

        with open('outfile1', 'rb') as fp:
            filtreli_kelimeler = pickle.load(fp)

        kelime_vektor = [0] * len(filtreli_kelimeler)

        def vektor_olusturma(text):
            text_kelimeler = text.split(" ")  # Textdeki kelimeleri ayırırız ve text_kelimelerde tutarız.
            text_vektor = [0] * len(kelime_vektor)
            for word in text_kelimeler:
                if word in filtreli_kelimeler:  # Textdeki kelimeler filtrelenmiş kelimelerde var ise döngü dönmeye devem edecek.
                    idx = filtreli_kelimeler.index(word)  # Kelimelerin listedeki konumu öğrenilir.
                    text_vektor[idx] += 1  # Kelime textde bulundukça dizisindeki değer artacaktır.

            return text_vektor  # text_vektor değerini döndürerek fonksiyon dışında kullanılabilir hale getirilir.

        filename = './models/randomforest1.sav'
        random_forest = pickle.load(open(filename, 'rb'))

        filename = './models/naivebayes1.sav'
        Mnb = pickle.load(open(filename, 'rb'))

        #haber = input("Haber metnini giriniz:")
        haber_vektor = vektor_olusturma(haber)
        kategori = Mnb.predict([haber_vektor])
        kategori_rf = random_forest.predict([haber_vektor])
        return (kategori)

    def uygula(self):

        import requests
        from bs4 import BeautifulSoup

        # Site tarafından bloklanmamak için gönderdiğimiz tarayıcı bilgileri
        headers = requests.utils.default_headers()

        url = str(self.alinanhaber.text())
        istek = requests.get(url, headers)
        soup = BeautifulSoup(istek.content, "lxml")
        print(soup)
# Learn News Name and Link From Website
        haberler = soup.find_all("div", {"class":"media-heading"})
        print(haberler)
        linkler = soup.find_all("p", {"class": "bbc-166eyoy e1tfxkuo1"})
        print("++++++++++++++++++++++++++++++++")
        print(linkler)
        liste = list()

        for i in linkler:
            print(i.text)
            liste.append(i.text)


        kategori_list = list()

        for i in liste:


            haber = i
            print(haber,"++")
            kategori = str(self.tahmin(haber))

            kategori_list.append(kategori)

        ekonomi = 0
        spor = 0
        dunya = 0
        siyaset = 0
        saglık = 0
        teknoloji = 0
        kultur = 0

        for i in kategori_list:
            if i == "['ekonomi ']":
                ekonomi += 1
            if i == "['spor ']":
                spor += 1
            if i == "['dunya ']":
                dunya += 1
            if i == "['saglık ']":
                saglık += 1
            if i == "['siyaset ']":
                siyaset += 1
            if i == "['kultur ']":
                kultur += 1
            if i == "['teknoloji ']":
                teknoloji += 1

        toplam = "Siyaset: "+ str(siyaset)+ '; '+  "Saglık: "+  str(saglık)+  '; '+ "Kültür: "+  str(kultur)+ '; '+ "Dünya: "+  str(dunya)+ '; '+ "Teknoloji: "+ str(teknoloji) + '; '+ "Spor:"+  str(spor)+ '; '+ "Ekonomi:"+  str(ekonomi)

        siyaset_y= int(siyaset/(siyaset+saglık+kultur+dunya+ teknoloji+spor+ekonomi)*100)
        saglık_y =  int(saglık/(siyaset+saglık+kultur+dunya+ teknoloji+spor+ekonomi)*100)
        dunya_y = int(dunya / (siyaset + saglık + kultur + dunya + teknoloji + spor + ekonomi) * 100)
        kultur_y = int(kultur / (siyaset + saglık + kultur + dunya + teknoloji + spor + ekonomi) * 100)
        teknoloji_y = int(teknoloji / (siyaset + saglık + kultur + dunya + teknoloji + spor + ekonomi) * 100)
        spor_y = int(spor/ (siyaset + saglık + kultur + dunya + teknoloji + spor + ekonomi) * 100)
        ekonomi_y = int(ekonomi / (siyaset + saglık + kultur + dunya + teknoloji + spor + ekonomi) * 100)
        #degisken = 'Yüzde<br>ooo<br>'
        maxyuz = [siyaset_y, saglık_y, dunya_y, kultur_y, teknoloji_y, spor_y, ekonomi_y]
        maxyuzs= (max(maxyuz))
        if  maxyuzs==siyaset_y:
            kat='Siyaset'
        if  maxyuzs==saglık_y:
            kat='Sağlık'
        if  maxyuzs==dunya_y:
            kat='Dünya'
        if  maxyuzs==kultur_y:
            kat='Kültür'
        if  maxyuzs==teknoloji_y:
            kat='Teknoloji'
        if  maxyuzs==spor_y:
            kat='Spor'
        if  maxyuzs==ekonomi_y:
            kat='Ekonomi'
        yuzdeler1 = 'Siyaset kategorisi %'+str(siyaset_y) + '<br>'+'Sağlık kategorisi %'+ str(saglık_y) + '<br>'+ 'Kültür kategorisi %'+ str(kultur_y) +'<br>'+'Dünya kategorisi %'+str(dunya_y) + '<br>'+'Teknoloji Kategorisi %'+ str(teknoloji_y) + '<br>'+ 'Spor Kategorisi %'+ str(spor_y) +'<br>'+ 'Ekonomi Kategorisi %'+ str(ekonomi_y)+'<br>' + 'En fazla bulunan kategori %'+ str(maxyuzs)+ ' ile '+str(kat)+ ' dır.'
        #yuzdeler2 = siyaset_y,"\n", "-"

        '''print('ahmet\nsasda')https://www.bbc.com/turkce
        print(siyaset_y,"\n", "-")
        print(yuzdeler1)
        #yuzdeler= ('{}\n{}\n{}\n{}\n{}\n{}\n{}'.format(saglık_y, siyaset_y, dunya_y,saglık_y,saglık_y,saglık_y,saglık_y,))
        print(toplam)'''
        self.giris.setText(toplam)
        print(yuzdeler1)
        self.yuzde.setText(yuzdeler1)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    pencere = Pencere()
    sys.exit(app.exec())
